
<div align="center" padding=25px>
    <img src="images/confluent.png" width=50% height=50%>
</div>

# <div align="center">Benchmarking Client Performance with Confluent Cloud</div>
## <div align="center">Workshop & Lab Guide</div>

## Background

The idea behind this workshop/lab guide is to provide a complete walk through of Kafka Tools for measuring Latency and Throughput when producing from various cloud and local environments to familiarize yourself with various producer/consumer configurations that tune performance.

The Kafka Tools that will be used to accomplish this will be:
- kafka-producer-perf-test
- kafka-consumer-perf-test
- kafka.tools.EndToEndLatency


This repository is meant to either be presented as a walk through by a member of the Confluent team, used as a demonstration without guided hands-on, or as a collection of artifacts that you can build on your own. All of the code used is available within the repository. 

***

## Prerequisites

First thing you'll need is a Confluent Cloud account. If you already have one, you can skip this, otherwise, you can try this completely free of charge and without adding payment details. The following link will bring you to a sign up page to get started. 
- [Get Started with Confluent Cloud for Free](https://www.confluent.io/confluent-cloud/tryfree/).

As you can expect, there are some tools that will be required to be successful with this lab. Please have the following in order to take full advantage of this workshop/lab guide.
- Docker
- jq

In addition to the necessary tools, this lab will use those tools to create resources in the cloud provider of your choice (what will be created will be explicitly stated in steps where you create it). These resources are used to create the end-to-end flow of data. The following states necessary credentials for each respective cloud provider.
- AWS
    - A user account with an API Key and Secret Key.
    - Appropriate permissions in a non-prod environment to create resources.
- GCP 
    - A non-prod project within which resources can be created.
    - A user account with a JSON Key file.
    - Appropriate permissions within the non-prod project to create resources.
- Azure
    - TBD.
    
## Step-by-Step

### Confluent Cloud Components

1. Clone and enter this repo.
    ```bash
    git clone https://github.com/ericmackay5/benchmarking-workshop
    ```
    ```bash
    cd benchmarking-workshop
    ```
1. Create a new "clipboard" file in the directory. Since a variety of credentials will be required, a place to keep track of them will be necessary. The following is the recommended approach. 
    ```bash 
    touch env.sh
    ```
    ```bash
    # Contents to create in env.sh ...

    # AWS Creds for TF
    export AWS_ACCESS_KEY_ID="<replace>"
    export AWS_SECRET_ACCESS_KEY="<replace>"
    export AWS_DEFAULT_REGION="us-east-2" # You can change this, but make sure it's consistent
    # GCP Creds for TF
    export TF_VAR_GCP_PROJECT=""
    export TF_VAR_GCP_CREDENTIALS=""
	# Confluent Cloud
	export BOOTSTRAP_SERVER=""
    ```
    > **Note:** *The impetus behind the above is so that you can easily `source env.sh` to have all the values available in the terminal.*

1. Create a cluster in Confluent Cloud. The recommended cluster type for this workshop/lab is either Basic/Standard.
    - [Create a Cluster in Confluent Cloud](https://docs.confluent.io/cloud/current/clusters/create-cluster.html).
    - Once the cluster is created, select its tile if you haven't, then select **Cluster overview > Cluster settings**. On the corresponding page, copy the value for **Bootstrap server** and paste it into your clipboard file under `BOOTSTRAP_SERVERS`. 

1. Create an API Key pair for for authentication to the cluster.
    - [Create API Keys](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html#ccloud-api-keys).
    - Once the keys have been generated, copy the values of the key and secret into the values of `KAFKA_KEY` and `KAFKA_SECRET` in your clipboard file respectively. 

***

### Build some cloud infrastructure

The next steps will vary between the various cloud providers. Use the following expandable sections to follow the relevant directions for the cloud provider of your choice. 
> **Note:** *While it might be obvious, it's worth mentioning that whatever cloud provider you created you Kafka cluster on should be the same cloud provider you use in the following steps.*

<details>
    <summary><b>AWS</b></summary>

1. Navigate to the AWS directory for Terraform.
    ```bash
    cd terraform/aws
    ```
1. Initialize Terraform within the directory.
    ```bash
    terraform init
    ```
1. Create the Terraform plan.
    ```bash
    terraform plan
    ```
1. Apply the plan and create the infrastructure.
    ```bash
    terraform apply
    ```
    > **Note:** *To see the inventory of what is created by this command, check out the configuration file [here](https://github.com/zacharydhamilton/realtime-datawarehousing/tree/main/terraform/aws).*

The Terraform configuration will create two outputs. These outputs are the public endpoints of the Postgres (Customers DB) and Postgres (Products DB) instances that were created. Keep these handy as you will need them in the connector configuration steps. 

</details>

<br>

<details>
    <summary><b>GCP</b></summary>

1. Navigate to the GCP directory for Terraform.
    ```bash
    cd terraform/gcp
    ```
1. Initialize Terraform within the directory.
    ```bash
    terraform init
    ```
1. Create the Terraform plan.
    ```bash
    terraform plan
    ```
1. Apply the plan and create the infrastructure.
    ```bash
    terraform apply
    ```
    > **Note:** *To see the inventory of what is created by this command, check out the configuration file [here](https://github.com/zacharydhamilton/realtime-datawarehousing/tree/main/terraform/gcp).*

The Terraform configuration will create two outputs. These outputs are the public endpoints of the Postgres (Customers DB) and Postgres (Products DB) instances that were created. Keep these handy as you will need them in the connector configuration steps. 


</details>

<br>

<details>
    <summary><b>Azure</b></summary>

Coming Soon!

</details>

<br>

***


    <summary><b>Clone the Repo to your EC2</b></summary>


 ```bash
git clone https://github.com/ericmackay5/benchmarking-workshop.git
 ```

```bash
docker run -v $PWD/producer.properties:/etc/producer.properties confluentinc/cp-server:7.3.0 /usr/bin/kafka-producer-perf-test \
    --topic performance-test \
    --num-records 1000000 \
    --record-size 512 \
    --throughput -1 \
    --producer.config /etc/producer.properties
```

```bash
docker run -v $PWD/consumer.properties:/etc/consumer.properties confluentinc/cp-server:7.3.0 /usr/bin/kafka-consumer-perf-test \
    --bootstrap-server ${BOOTSTRAP_SERVER} \
    --topic performance-test \
    --messages 1000000 \
    --consumer.config /etc/consumer.properties | \
jq -R .|jq -sr 'map(./",")|transpose|map(join(": "))[]'
```

```bash
docker run -v $PWD/endtoend.properties:/etc/endtoend.properties confluentinc/cp-server:7.3.0 /usr/bin/kafka-run-class kafka.tools.EndToEndLatency pkc-n00kk.us-east-1.aws.confluent.cloud:9092 endtoendlatency 100000 1 512 /etc/endtoend.properties
```


## Cleanup

When you're done with all of the resources created in this lab, **be sure to delete everything you provisioned** in an effort to mitigate the chances of being changed for anything. 

### Confluent Cloud
During this lab you created the following resources, be sure to remove them when you're done with them.
- Ksql Cluster
- Delta Lake Sink Connector
- Postgres CDC Source Connector (Customers)
- Postgres CDC Source Connector (Products)
- Kafka Cluster

### Terraform
To remove everything provisioned by Terraform in either AWS, GCP, or Azure, use the following command.

```bash
terraform destroy
```
