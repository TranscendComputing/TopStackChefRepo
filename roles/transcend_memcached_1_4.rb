name "transcend_memcached_1_4"
    description "Elasticache Memcached Engine Version 1.4."
    run_list(["recipe[transcend_memcached]"])
    # Attributes applied if the node doesn't have it set already.
    #default_attributes()
    # Attributes applied no matter what the node has set already.
    #override_attributes()
