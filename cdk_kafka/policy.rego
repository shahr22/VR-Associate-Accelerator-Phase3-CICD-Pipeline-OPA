package rules


security_groups := [sg | input.Resources[i].Type == "AWS::EC2::SecurityGroup"; sg := input.Resources[i].Properties.SecurityGroupIngress]

cidr_open {
	 some group, in_rule
     	security_groups[group][in_rule].CidrIp = "0.0.0.0/0"
}


iam_statements := [pol | input.Resources[i].Type == "AWS::IAM::Policy"; pol := input.Resources[i].Properties.PolicyDocument.Statement]

permissive_action {
	 some i,j,k
        contains(iam_statements[i][j].Action[k], "*")
}

permissive_resource {
	 some i,j
        contains(iam_statements[i][j].Resource, "*")
}

bucket_policies := [pol | input.Resources[i].Type == "AWS::S3::BucketPolicy"; pol := input.Resources[i].Properties.PolicyDocument]

open_bucket_policy {
	 some i,k
        bucket_policies[i].Statement[k].Principal.AWS == "*"
}

open_bucket_policy {
	 some i,k
        bucket_policies[i].Statement[k].Principal == "*"
}

bucket_acl := [acl | input.Resources[i].Type == "AWS::S3::Bucket"; acl := input.Resources[i].Properties.AccessControl]

open_bucket_acl {
	some i
    	bucket_acl[i] = "PublicRead"
}

open_bucket_acl {
	some i
    	bucket_acl[i] = "PublicReadWrite"
}

open_bucket_acl {
	some i
    	bucket_acl[i] = "AuthenticatedRead"
}

fail["Quad Zero Access"] {
	cidr_open
}

fail["IAM asterisk not allowed (actions)"] {
	permissive_action
}

fail["IAM asterisk not allowed (resources)"] {
	permissive_resource
}

fail["S3 bucket public access (ACLs)"] {
	open_bucket_acl
}

fail["S3 bucket public access (policies)"] {
	open_bucket_policy
}