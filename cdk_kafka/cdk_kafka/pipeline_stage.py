from constructs import Construct
from aws_cdk import (
    Stage
)
from .cdk_kafka_stack import CdkKafkaStack

class KafkaPipelineStage(Stage):

    def __init__(self, scope: Construct, id: str, **kwargs):
        super().__init__(scope, id, **kwargs)

        service = CdkKafkaStack(self, 'Kafka')