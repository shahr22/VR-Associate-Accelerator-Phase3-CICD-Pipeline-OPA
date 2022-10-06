from aws_cdk import (
    Stack,
    aws_ec2 as ec2
    
)
from constructs import Construct

with open("./cdk_kafka/user_data.sh") as ud:
    user_data = ud.read()

# Inputs
vpc_cidr = '10.0.0.0/16'
subnet_mask = 24 
key_pair = 'testkp'
instance_type = 't2.medium'

class CdkKafkaStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.vpc = ec2.Vpc(self, 'kafka_vpc',
            cidr = vpc_cidr,
            max_azs = 1,
            enable_dns_hostnames = True,
            enable_dns_support = True, 
            # Will be deployed into a public subnet
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name = 'PublicSN',
                    subnet_type = ec2.SubnetType.PUBLIC,
                    cidr_mask = subnet_mask
                ),
            ],
            nat_gateways = 0,

        )
        # Gets latest Amazon Linux AMI
        amzn_linux = ec2.MachineImage.latest_amazon_linux(
            generation=ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
            edition=ec2.AmazonLinuxEdition.STANDARD,
            virtualization=ec2.AmazonLinuxVirt.HVM,
            storage=ec2.AmazonLinuxStorage.GENERAL_PURPOSE
            )

        kafka_sg = ec2.SecurityGroup(self, "KafkaSG",
            vpc=self.vpc,
            allow_all_outbound=True
        )
        # Security group opens up Kafka's required ports
        kafka_sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(22))
        kafka_sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp_range(2888, 3888))
        kafka_sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(9092))
        kafka_sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(2181))         

        kafka = ec2.Instance(self, "Kafka",
            instance_type=ec2.InstanceType(instance_type),
            machine_image=amzn_linux,
            vpc = self.vpc,
            vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PUBLIC),
            key_name=key_pair,
            user_data=ec2.UserData.custom(user_data),
            security_group=kafka_sg,
            )

