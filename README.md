
Install Raspbian on to the SD card inside a Raspbarry PI 3.


1, Upon first boot open a terminal window then complete the following manual steps

a), change the 'PI' users password

```
passwd
```

b) enable and start OpenSSH Server

```
sudo systemctl enable ssh
sudo systemctl start ssh
```

2, Build Filebeat binary

```
#----- Create a Docker for cross-compilation -----#
mkdir build && cd $_
docker run -it --rm -v `pwd`:/build golang:1.8.3 /bin/bash
#----- Inside docker -----#
go get github.com/elastic/beats       
cd /go/src/github.com/elastic/beats/filebeat/
git checkout v6.1.1
GOARCH=arm go build
cp filebeat /build
exit
cd ../
cp build/filebeat roles/filebeat/files/
```

3, Update the ansible site.yml and vars.yml with the correct settings for your local device then run.

```
ansible-playbook -i hosts -k -e @vars.yml site.yml
```
