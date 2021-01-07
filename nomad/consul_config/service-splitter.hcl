kind = "service-splitter"
name = "backend"
splits = [
	{
		weight = 50
		service_subset = "v1"
	},
	{
		weight = 50
		service_subset = "v2"
	}
]
