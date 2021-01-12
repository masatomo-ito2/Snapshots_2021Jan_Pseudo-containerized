# HashiCorp Snapshot Pseudo-containerized (Jan 2021)

## Demo environment set up

**If you already have Nomad/Consul cluster, please ignore this section.**

1. Go to `terraform` directory.

2. Modifiy `variables.tf` to match your AWS settings

3. Run `terraform apply`

	This apply creates Nomad and Consul server and clients.

4. Once `apply` finishes, go to `nomad` directory.

	Run:

```
. env_setup.sh
```

	This script will set some environment variables necessary for consul and nomad to work.

- NOMAD_ADDR
- CONSUL_ADDR
- CONSUL_HTTP_ADDR
- CONSUL_HTTP_TOKEN

## Build an artifact

1. Go to `nomad/artifact` directory.

	There are 2 GO programs, frontend and backend.
	Frontend app requests backend app for some data and renders a webpage with data embedded.

2. Modify `Makefile`

	Please set S3 bucket and object to yours. This is where the artifacts will be stored.

3. Run `make` to build and deploy (s3 upload) your apps.

## Nomad job file

1. Please change the `local.artifact` variable to your S3 path.

## Run the demo

1. Submit job file to Nomad.

```
nomad job run run_front_back.nomad
```

2. Nomad will deploy frontend and backend apps, and registers the app to Consul service catalog.

	**you can access the Nomad UI at $NOMAD_ADDR**

3. Check consul's service catalog

	**you can access the Consul UI at $CONSUL_HTTP_ADDR**

4. Once `frontend` service becomes healthy, run following script to get a frontend URL.

```
./get_frontend_url.sh
```

	Access the URL to see your application.

## Additional things to try

### Change the number of services to deploy.

- Change `attrib_v1.["task_count"]

```
ariable attrib_v1 {
	type = object({
		version = string,
		task_count = number,
		text_color = string,
	})
	default = {
		version = "v1",
		task_count = 1,		// <----
		text_color = "green",
	}
}
```

### Deploy app v2

- Change `attrib_v2.["task_count"]

```
variable attrib_v2 {
	type = object({
		version = string,
		task_count = number,
		text_color = string,
	})
	default = {
		version = "v2",
		task_count = 0,   // <-----
		text_color = "red",
	}
}
```

### Set L7 routing

1. Go to `consul_config` directory.

2. Examine L7 routing settings.

- service-defaults.hcl
- service-resolver.hcl
- service-router.hcl

3. Run the script or commands to set the config

```
consul config write service-defaults.hcl
consul config write service-resolver.hcl
consul config write service-router.hcl
```

4. Additionally you can try splitter.

- service-splitter.hcl

```
consul config write service-splitter.hcl
```


