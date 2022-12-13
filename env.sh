# increased partitions allows for more throughput. Count depends on use case.
export partitions=6

# important for data durability. Advised to set to 3.
export replication_factor=3

# topic configuration that will affect acks parameter from producer config. When acks=all we can tolerate (#replication.factor) - (#min.insync.replicas) brokers going down
export min_insync_replicas=2

export BOOTSTRAP_SERVER="<<BOOTSRATP_SERVER>>"
export CLUSTER_API_KEY='<<CLUSTER_API_KEY>>'
export CLUSTER_SECRET_KEY='<<CLUSTER_SECRET_KEY>>'
