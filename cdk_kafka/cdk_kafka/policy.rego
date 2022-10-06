package rules

# Define rules as security checks. If a single rule valuates to true, policy will fail.

# Get all security groups
security_groups := [sg | input.Resources[i].Type == "AWS::EC2::SecurityGroup"; sg := input.Resources[i].Properties.SecurityGroupIngress]

cidr_open {
	 some group, in_rule
     	security_groups[group][in_rule].CidrIp = "0.0.0.0/0" #checks for quad zero access
}

# Get IAM policies
iam_statements := [pol | input.Resources[i].Type == "AWS::IAM::Policy"; pol := input.Resources[i].Properties.PolicyDocument.Statement]

permissive_action {
	 some i,j,k
        contains(iam_statements[i][j].Action[k], "*") # checks for IAM actions allowing "*"
}

permissive_resource {
	 some i,j
        contains(iam_statements[i][j].Resource, "*") # checks for IAM resource access allowing "*"
}

# Get Bucket policies
bucket_policies := [pol | input.Resources[i].Type == "AWS::S3::BucketPolicy"; pol := input.Resources[i].Properties.PolicyDocument]

open_bucket_policy {
	 some i,k
        bucket_policies[i].Statement[k].Principal.AWS == "*" # Checks for AWS authenticated access
}

open_bucket_policy {
	 some i,k
        bucket_policies[i].Statement[k].Principal == "*" # Checks for public/all access
}

# Get bucket ACLs
bucket_acl := [acl | input.Resources[i].Type == "AWS::S3::Bucket"; acl := input.Resources[i].Properties.AccessControl]

# Check for various levels of public access (Public Read/ReadWrite, AuthenticatedRead)

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

# Summarize rule failiures into a list

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