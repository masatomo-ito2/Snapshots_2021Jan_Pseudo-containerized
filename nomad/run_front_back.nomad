locals {
	mode = "Legacy"
}

variables {
	backend_task_count = 2
	frontend_port = 8080
	upstream_port = 10000
}

variable attrib {
	type = map(string)
	default = {
		version = "v1",
		text_color = "green",
	}
}

job "frontback_job" {

  region = "global"

  datacenters = ["dc1"]

  type = "service"

	#####################
	#                   #
	#      Backend      #
	#                   #
	#####################

	group "backend_group" {

		count = var.backend_task_count

		network {
			mode = "bridge"
			port "http" {}
		}

		service {
			name = "backend"
			port = "http"

			connect {
				sidecar_service {}
			}

			meta {
				version = var.attrib["version"]
			}

			check {
				type     = "http"
				path     = "/"
				interval = "5s"
				timeout  = "3s"
			}

			tags = [
				"Snapshots",
				"Backend",
				local.mode,
				var.attrib["version"]
			]
		}

		task "backend" {

      driver = "exec"

			artifact {
				source = "https://hashicorpjp.s3.ap-northeast-1.amazonaws.com/masa/frontback.tgz"
			}

			env {
				COLOR     = var.attrib[ "text_color" ]
				MODE	  	= local.mode
				TASK_ID		= "${NOMAD_ALLOC_INDEX}"
				ADDR      = "${NOMAD_ADDR_http}"
				PORT      = "${NOMAD_PORT_http}"
				VERSION   = var.attrib["version"]
			}

      config {
				command = "backend"
      }

			resources {
				cpu = 50       # reserve 50 MHz
				memory = 32    # reserve 32 MB
			}

    }

		reschedule {
			delay = "10s"
			delay_function = "constant"
		}
  }

	######################
	#                    #
	#      Frontend      #
	#                    #
	######################

	group "frontend_group" {

		count = 1

		network {
			mode = "bridge"
			port "http" {
				static = var.frontend_port
			}	
		}

		service {
			name = "frontend"
			port = "http"

			connect {
				sidecar_service {
					proxy {
						upstreams {
							destination_name = "backend"
							local_bind_port  = var.upstream_port
						}
					}
				}
			}

			check {
				type     = "http"
				path     = "/"
				interval = "5s"
				timeout  = "3s"
			}
			
			tags = [
				local.mode,
				"Snapshots",
				"Frontend"
			]
		}

    task "frontend" {

      driver = "exec"

			artifact {
				source = "https://hashicorpjp.s3.ap-northeast-1.amazonaws.com/masa/frontback.tgz"
			}

			env {
				PORT      		= "${NOMAD_PORT_http}"
				UPSTREAM_URL	= "http://${NOMAD_UPSTREAM_ADDR_backend}"
			}

      config {
				command = "frontend"
      }

    }

		reschedule {
			delay = "10s"
			delay_function = "constant"
		}
  }
}
