# increased partitions allows for more throughput. Count depends on use case.
export partitions=6

# important for data durability. Advised to set to 3.
export replication.factor=3

# topic configuration that will affect acks parameter from producer config. When acks=all we can tolerate (#replication.factor) - (#min.insync.replicas) brokers going down
export min.insync.replicas=2

export BOOTSTRAP_SERVER=pkc-n00kk.us-east-1.aws.confluent.cloud:9092