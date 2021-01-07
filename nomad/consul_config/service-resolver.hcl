Kind = "service-resolver"
Name = "backend"

DefaultSubset = "v1"

Subsets = {
	"v1" = {
		Filter = "Service.Meta.version == v1"
	}
	"v2" = {
		Filter = "Service.Meta.version == v2"
	}
}
