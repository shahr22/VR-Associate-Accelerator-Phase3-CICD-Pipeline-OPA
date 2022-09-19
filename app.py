#!/usr/bin/env python3

import aws_cdk as cdk
from cdk_kafka.pipeline_stack import KafkaPipelineStack

app = cdk.App()
KafkaPipelineStack(app, "KafkaPipelineStack")

app.synth()
