package rules.tf_google_compute_firewall_port_25

import data.google.compute.firewall_library as lib

import data.fugue

__rego__metadoc__ := {
	"id": "FR50",
	"custom": {
	    "controls": {
	        "tool_detail": [
	            "DSS05.02.6"
	        ],
	        "implementation": [
	            "DSS05.02.6"
	        ],
	        "test_definition": [
	            "DSS05.02.2"
	        ]
	      },
        "severity": "High"
    },
	"description": "Network firewall rules should not permit ingress from 0.0.0.0/0 to port 25 (SMTP). It reduces a server's exposure to risk.",
	"title": "Network firewall rules should not permit ingress from 0.0.0.0/0 to port 25 (SMTP)",
}

firewalls = fugue.resources("google_compute_firewall")

resource_type := "MULTIPLE"

port = "25"

policy[j] {
	firewall = firewalls[_]
	network = lib.network_for_firewall(firewall)
	lib.is_network_vulnerable(network, port)
	j = fugue.allow_resource(firewall)
}

policy[j] {
	firewall = firewalls[_]
	network = lib.network_for_firewall(firewall)
	not lib.is_network_vulnerable(network, port)
	p = lib.lowest_allow_ingress_zero_cidr_by_port(network, port)
	f = lib.firewalls_by_priority_and_port(network, p, port)[_]
	j = fugue.deny_resource(f)
}
