Kind = "service-router"
Name = "backend"

Routes = [
	{
		Match {
			HTTP {
				QueryParam = [
					{
						Name = "version"
						Exact = "v1"
					},
				]
			}
		}
		Destination {
			Service = "backend"
			ServiceSubset = "v1"
		}	
	},
	{
		Match {
			HTTP {
				QueryParam = [
					{
						Name = "version"
						Exact = "v2"
					},
				]
			}
		}
		Destination {
			Service = "backend"
			ServiceSubset = "v2"
		}	
	},
	{
		Match {
			HTTP {
				PathExact = "/v1"
			}
		}
		Destination {	
			Service = "backend"
			ServiceSubset = "v1"	
		}	
	},
	{
		Match {
			HTTP {
				PathExact = "/v2"
			}
		}
		Destination {	
			Service = "backend"
			ServiceSubset = "v2"	
		}	
	},
]
