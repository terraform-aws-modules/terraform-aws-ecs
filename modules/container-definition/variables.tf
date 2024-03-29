variable "operating_system_family" {
  description = "The OS family for task"
  type        = string
  default     = "LINUX"
}

################################################################################
# Container Definition
################################################################################

variable "command" {
  description = "The command that's passed to the container"
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of `cpu` of all containers in a task will need to be lower than the task-level cpu value"
  type        = number
  default     = null
}

variable "dependencies" {
  description = "The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY"
  type = list(object({
    condition     = string
    containerName = string
  }))
  default = []
}

variable "disable_networking" {
  description = "When this parameter is true, networking is disabled within the container"
  type        = bool
  default     = null
}

variable "dns_search_domains" {
  description = "Container DNS search domains. A list of DNS search domains that are presented to the container"
  type        = list(string)
  default     = []
}

variable "dns_servers" {
  description = "Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers"
  type        = list(string)
  default     = []
}

variable "docker_labels" {
  description = "A key/value map of labels to add to the container"
  type        = map(string)
  default     = {}
}

variable "docker_security_options" {
  description = "A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems. This field isn't valid for containers in tasks using the Fargate launch type"
  type        = list(string)
  default     = []
}

variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
}

variable "entrypoint" {
  description = "The entry point that is passed to the container"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "The environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "environment_files" {
  description = "A list of files containing the environment variables to pass to a container"
  type = list(object({
    value = string
    type  = string
  }))
  default = []
}

variable "essential" {
  description = "If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
  type        = bool
  default     = null
}

variable "extra_hosts" {
  description = "A list of hostnames and IP address mappings to append to the `/etc/hosts` file on the container"
  type = list(object({
    hostname  = string
    ipAddress = string
  }))
  default = []
}

variable "firelens_configuration" {
  description = "The FireLens configuration for the container. This is used to specify and configure a log router for container logs. For more information, see [Custom Log Routing](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html) in the Amazon Elastic Container Service Developer Guide"
  type        = any
  default     = {}
}

variable "health_check" {
  description = "The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html)"
  type        = any
  default     = {}
}

variable "hostname" {
  description = "The hostname to use for your container"
  type        = string
  default     = null
}

variable "image" {
  description = "The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
  default     = null
}

variable "interactive" {
  description = "When this parameter is `true`, you can deploy containerized applications that require `stdin` or a `tty` to be allocated"
  type        = bool
  default     = false
}

variable "links" {
  description = "The links parameter allows containers to communicate with each other without the need for port mappings. This parameter is only supported if the network mode of a task definition is `bridge`"
  type        = list(string)
  default     = []
}

variable "linux_parameters" {
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html)"
  type        = any
  default     = {}
}

variable "log_configuration" {
  description = "The log configuration for the container. For more information see [LogConfiguration](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html)"
  type        = any
  default     = {}
}

variable "memory" {
  description = "The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. The total amount of memory reserved for all containers within a task must be lower than the task `memory` value, if one is specified"
  type        = number
  default     = null
}

variable "memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container. When system memory is under heavy contention, Docker attempts to keep the container memory to this soft limit. However, your container can consume more memory when it needs to, up to either the hard limit specified with the `memory` parameter (if applicable), or all of the available memory on the container instance"
  type        = number
  default     = null
}

variable "mount_points" {
  description = "The mount points for data volumes in your container"
  type        = list(any)
  default     = []
}

variable "name" {
  description = "The name of a container. If you're linking multiple containers together in a task definition, the name of one container can be entered in the links of another container to connect the containers. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed"
  type        = string
  default     = null
}

variable "port_mappings" {
  description = "The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort"
  type        = list(any)
  default     = []
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)"
  type        = bool
  default     = false
}

variable "pseudo_terminal" {
  description = "When this parameter is true, a `TTY` is allocated"
  type        = bool
  default     = false
}

variable "readonly_root_filesystem" {
  description = "When this parameter is true, the container is given read-only access to its root file system"
  type        = bool
  default     = true
}

variable "repository_credentials" {
  description = "Container repository credentials; required when using a private repo.  This map currently supports a single key; \"credentialsParameter\", which should be the ARN of a Secrets Manager's secret holding the credentials"
  type        = map(string)
  default     = {}
}

variable "resource_requirements" {
  description = "The type and amount of a resource to assign to a container. The only supported resource is a GPU"
  type = list(object({
    type  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "start_timeout" {
  description = "Time duration (in seconds) to wait before giving up on resolving dependencies for a container"
  type        = number
  default     = 30
}

variable "stop_timeout" {
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own"
  type        = number
  default     = 120
}

variable "system_controls" {
  description = "A list of namespaced kernel parameters to set in the container"
  type        = list(map(string))
  default     = []
}

variable "ulimits" {
  description = "A list of ulimits to set in the container. If a ulimit value is specified in a task definition, it overrides the default values set by Docker"
  type = list(object({
    hardLimit = number
    name      = string
    softLimit = number
  }))
  default = []
}

variable "user" {
  description = "The user to run as inside the container. Can be any of these formats: user, user:group, uid, uid:gid, user:gid, uid:group. The default (null) will use the container's configured `USER` directive or root if not set"
  type        = string
  default     = null
}

variable "volumes_from" {
  description = "Data volumes to mount from another container"
  type        = list(any)
  default     = []
}

variable "working_directory" {
  description = "The working directory to run commands inside the container"
  type        = string
  default     = null
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "service" {
  description = "The name of the service that the container definition is associated with"
  type        = string
  default     = ""
}

variable "enable_cloudwatch_logging" {
  description = "Determines whether CloudWatch logging is configured for this container definition. Set to `false` to use other logging drivers"
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Custom name of CloudWatch log group for a service associated with the container definition"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_use_name_prefix" {
  description = "Determines whether the log group name should be used as a prefix"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default is 30 days"
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
