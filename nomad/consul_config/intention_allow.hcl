Kind = "service-intentions"
Name = "backend"

Sources = [
	{
		Name = "frontend"

# L4 intention
		Action = "allow"
# L7 intention
/*
		Permissions = [
			{
				Action = "allow"
				HTTP  {
					Methods = [ "GET" ]
				}
			}
		]
*/
	}
]
