locals {
  mode     = "Legacy"
  artifact = "https://hashicorpjp.s3.ap-northeast-1.amazonaws.com/masa/Snapshots2021Jan_Nomad/frontback.tgz"
  # img_dir  = "https://hashicorpjp.s3-ap-northeast-1.amazonaws.com/masa/Snapshots2021Jan_Nomad/"
}

variables {
  frontend_port = 8080
  upstream_port = 10000
}

variable "attrib_v1" {
  type = object({
    version    = string,
    task_count = number,
    text_color = string,
  })
  default = {
    version    = "v1",
    task_count = 1,
    text_color = "green",
  }
}

variable "attrib_v2" {
  type = object({
    version    = string,
    task_count = number,
    text_color = string,
  })
  default = {
    version    = "v2",
    task_count = 0,
    text_color = "red",
  }
}

job "frontback_job" {

  region = "global"

  datacenters = ["dc1"]

  type = "service"

  #######################
  #                     #
  #      Backend v1     #
  #                     #
  #######################

  group "backend_group_v1" {

    count = var.attrib_v1["task_count"]

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
        version = var.attrib_v1["version"]
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
        var.attrib_v1["version"]
      ]
    }

    task "backend" {

      driver = "exec"

      artifact {
        source = local.artifact
      }

      env {
        COLOR   = var.attrib_v1["text_color"]
        MODE    = local.mode
        TASK_ID = NOMAD_ALLOC_INDEX
        ADDR    = NOMAD_ADDR_http
        PORT    = NOMAD_PORT_http
        VERSION = var.attrib_v1["version"]
        # IMG_SRC		= "${local.img_dir}${var.attrib_v1["version"]}.png"
      }

      config {
        command = "backend"
      }

      resources {
        memory = 32  # reserve 32 MB
        cpu    = 100 # reserve 100 MHz
      }

    }

    reschedule {
      delay          = "10s"
      delay_function = "constant"
    }
  }

  #######################
  #                     #
  #      Backend v2     #
  #                     #
  #######################

  group "backend_group_v2" {

    count = var.attrib_v2["task_count"]

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
        version = var.attrib_v2["version"]
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
        var.attrib_v2["version"]
      ]
    }

    task "backend" {

      driver = "exec"

      artifact {
        source = local.artifact
      }

      env {
        COLOR   = var.attrib_v2["text_color"]
        MODE    = local.mode
        TASK_ID = NOMAD_ALLOC_INDEX
        ADDR    = NOMAD_ADDR_http
        PORT    = NOMAD_PORT_http
        VERSION = var.attrib_v2["version"]
        # IMG_SRC		= "${local.img_dir}${var.attrib_v2["version"]}.png"
      }

      config {
        command = "backend"
      }

      resources {
        memory = 32  # reserve 32 MB
        cpu    = 100 # reserve 100 MHz
      }
    }

    reschedule {
      delay          = "10s"
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

      /*
			check {
				type     = "http"
				path     = "/"
				interval = "5s"
				timeout  = "3s"
			}
			*/

      tags = [
        local.mode,
        "Snapshots",
        "Frontend"
      ]
    }

    task "frontend" {

      driver = "exec"

      artifact {
        source = local.artifact
      }

      env {
        PORT         = NOMAD_PORT_http
        UPSTREAM_URL = "http://${NOMAD_UPSTREAM_ADDR_backend}"
      }

      config {
        command = "frontend"
      }

      resources {
        memory = 32  # reserve 32 MB
        cpu    = 100 # reserve 100 MHz
      }

    }

    reschedule {
      delay          = "10s"
      delay_function = "constant"
    }
  }
}
