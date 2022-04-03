terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
 
provider "digitalocean" {
   token = var.DO_token
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}
 
resource "digitalocean_ssh_key" "my_key" {
  name = "DOMYKEY"
  
   public_key = var.my_DO_rsa
}
 

 data "external" "do_finger" {
  program = ["bash","fingerprint.sh"]

  query = {
    
    access = var.DO_token
    key = var.key_name
  }
}

resource "digitalocean_droplet" "ksumag" {
  image = "ubuntu-20-04-x64"
  name = "ksumag-1"
  region = "fra1"
  size = "s-1vcpu-1gb"
  tags = ["devops", "dymon_ksu_at_gmail_com"]
  ssh_keys = [digitalocean_ssh_key.my_key.fingerprint, data.external.do_finger.result.fingerprint]
}


data "aws_route53_zone" "primary" {
  name = "devops.rebrain.srwx.net"
  
}
resource "aws_route53_record" "myrecord" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "dymon_ksu_at_gmail_com.devops.rebrain.srwx.net"
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.ksumag.ipv4_address]
}