`count` in Terraform is used to create multiple copies of the same resource, module, or data source automatically.

---

# Direct Explanation of `count`

Example:

```hcl id="w7e3tl"
resource "aws_instance" "web" {
  count = 3

  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```

Terraform creates:

```text id="s0fslh"
aws_instance.web[0]
aws_instance.web[1]
aws_instance.web[2]
```

So instead of writing the resource 3 times manually, Terraform loops for you.

---

# How `count` Works

`count` accepts a number:

```hcl id="mpx5b6"
count = <integer>
```

Terraform then creates that many instances of the resource.

---

# Step-by-Step Example

## Without `count`

You would write:

```hcl id="lhdb3t"
resource "aws_instance" "web1" {}
resource "aws_instance" "web2" {}
resource "aws_instance" "web3" {}
```

This is repetitive.

---

## With `count`

```hcl id="9hxbx5"
resource "aws_instance" "web" {
  count = 3
}
```

Terraform automatically creates 3 instances.

---

# What Is `count.index`?

Inside a counted resource, Terraform exposes:

```hcl id="o6b3wa"
count.index
```

This is the current iteration number.

Indexes start at `0`.

Example:

| Resource | count.index |
| -------- | ----------- |
| web[0]   | 0           |
| web[1]   | 1           |
| web[2]   | 2           |

---

# Common Usage

## 1. Creating Multiple Subnets

```hcl id="ny8o5k"
resource "aws_subnet" "private" {
  count      = 3
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
}
```

Creates:

```text id="t6q8q3"
Subnet 0
Subnet 1
Subnet 2
```

---

## 2. Naming Resources Dynamically

```hcl id="49qt9g"
resource "aws_instance" "web" {
  count = 3

  tags = {
    Name = "web-${count.index}"
  }
}
```

Results:

```text id="rcwbvd"
web-0
web-1
web-2
```

---

## 3. Conditional Resource Creation

Very common pattern:

```hcl id="v7qxq2"
count = var.create_instance ? 1 : 0
```

Meaning:

* create resource if true
* create nothing if false

Example:

```hcl id="h61e7e"
resource "aws_instance" "web" {
  count = var.enable_ec2 ? 1 : 0
}
```

---

# Visual Representation

If:

```hcl id="tixs5f"
count = 4
```

Terraform internally thinks like:

```text id="b32h9r"
for i in [0,1,2,3]:
    create resource
```

---

# Important Behavior

## Resource Address Changes

Terraform tracks counted resources by index.

Example:

```hcl id="cfdy06"
count = 3
```

Creates:

```text id="jlwmvg"
[0]
[1]
[2]
```

If later changed to:

```hcl id="pn5ttf"
count = 2
```

Terraform destroys:

```text id="vjlwmx"
[2]
```

---

# Dangerous Scenario

Suppose:

```hcl id="2uw7ow"
count = length(var.instances)
```

and:

```hcl id="ex6jdf"
var.instances = ["app", "db", "cache"]
```

Indexes:

| Index | Value |
| ----- | ----- |
| 0     | app   |
| 1     | db    |
| 2     | cache |

If you remove `"db"`:

```hcl id="mec68m"
["app", "cache"]
```

Terraform sees:

```text id="rj9r2x"
old [1] = db
new [1] = cache
```

Result:

* destroys old resource
* recreates cache resource

This is why `count` can be risky for mutable lists.

---

# Better Alternative: `for_each`

Modern Terraform often prefers:

```hcl id="x8tvq0"
for_each = toset(["app", "db", "cache"])
```

Because resources are tracked by name instead of index.

---

# `count` vs `for_each`

| Feature                         | count | for_each        |
| ------------------------------- | ----- | --------------- |
| Uses numeric indexes            | Yes   | No              |
| Best for identical resources    | Yes   | Yes             |
| Best for unique named resources | No    | Yes             |
| Sensitive to list ordering      | Yes   | No              |
| Easier for beginners            | Yes   | Slightly harder |

---

# Real Production Example

```hcl id="g0fy8l"
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index + 10
  )

  tags = {
    Name = "private-subnet-${count.index}"
  }
}
```

Creates:

| Resource   | CIDR         |
| ---------- | ------------ |
| private[0] | 10.0.10.0/24 |
| private[1] | 10.0.11.0/24 |
| private[2] | 10.0.12.0/24 |

---

# Common Beginner Mistakes

## 1. Forgetting `count.index`

Bad:

```hcl id="e7wbmv"
Name = "server"
```

All resources get same name.

Better:

```hcl id="v49dgb"
Name = "server-${count.index}"
```

---

## 2. Using `count` with Changing Lists

Can cause unexpected destruction/recreation.

Prefer:

```hcl id="mm2rdv"
for_each
```

for stable infrastructure.

---

# Mental Model

Think of:

```hcl id="m1rqou"
count
```

as:

```text id="ol0tds"
repeat this resource N times
```

And:

```hcl id="8qu7lq"
count.index
```

as:

```text id="g3o9n9"
which repetition am I currently on?
```

---

# Action Plan

To master `count`:

1. Create one EC2 resource manually.
2. Convert it to:

   ```hcl
   count = 3
   ```
3. Add:

   ```hcl
   count.index
   ```

   into tags/names.
4. Run:

   ```bash
   terraform plan
   ```
5. Observe indexed resources.

Success criteria:

* You understand indexed resource creation.
* You can predict resource addresses.
* You know when to use `count` vs `for_each`.

If you want, I can also explain:

* `for_each` deeply
* Terraform resource addressing
* how Terraform state tracks `count`
* why index shifting causes destruction
* advanced looping patterns in Terraform modules

