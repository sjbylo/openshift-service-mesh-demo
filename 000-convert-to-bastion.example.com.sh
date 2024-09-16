reg_host=bastion.example.com
reg_port=8443
reg_path=ocp4
sed -i "s#quay\.io#$reg_host:$reg_port/$reg_path#g" */*.yaml */*/*.yaml */*/*/*.yaml &&  # required since other methods are messy
sed -i "s/source: .*/source: cs-redhat-operator-index/g" operators/*

