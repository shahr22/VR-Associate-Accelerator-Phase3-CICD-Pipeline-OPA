from constructs import Construct
from aws_cdk import (
    Stack,
    aws_codecommit as codecommit,
    pipelines as pipelines,
)
from cdk_kafka.pipeline_stage import KafkaPipelineStage

class KafkaPipelineStack(Stack):

    def __init__(self, scope: Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        repo = codecommit.Repository(
            self, 'KafkaRepo',
            repository_name= "KafkaRepo"
        )
        
        # Uses CDK Pipelines instead of aws-codepipeline
        
        pipeline = pipelines.CodePipeline(
            self,
            "Pipeline",
            synth=pipelines.ShellStep(
                "Synth and Evaluate",
                input=pipelines.CodePipelineSource.code_commit(repo, "master"),
                commands=[
                    "npm install -g aws-cdk",  # Installs the cdk cli on Codebuild
                    "pip install -r requirements.txt",  # Instructs Codebuild to install required packages
                    "cdk synth",
                    "curl -L -o opa https://openpolicyagent.org/downloads/v0.44.0/opa_linux_amd64_static",
                    "chmod 755 ./opa",
                    './opa eval --fail-defined -i ./cdk.out/CdkKafkaStack.template.json -d ./cdk_kafka/policy.rego "data"',
                ],
                primary_output_directory="cdk.out",
            ),
        )

        deploy = KafkaPipelineStage(self, "Deploy")
        deploy_stage = pipeline.add_stage(deploy)
        