#  eureka-cluster
   -  实例数：2
   -  端口：30001&30002
   
## java 启动脚本
```bash

nohup java -Dspring.profiles.active=stgMaster -jar eureka-server-0.0.1-SNAPSHOT.jar >eureka-master.log 2>&1 & 
```
```bash
nohup java -Dspring.profiles.active=stgSlave -jar eureka-server-0.0.1-SNAPSHOT.jar >eureka-slave.log 2>&1 & 
```

## docker-compose 编排
```yaml
version: '3'

services:
  mcd-emsb-registry-master:
    image: mcd-emsb-registry-clusters
    container_name: mcd-emsb-registry-master
    networks:
      - mcd-local-bridge
    ports:
      - 10000:10000
    environment:
      spring.profiles.active: stgMaster
      
  mcd-emsb-registry-slave:
      image: mcd-emsb-registry-clusters
      container_name: mcd-emsb-registry-slave
      networks:
        - mcd-local-bridge
      ports:
        - 10001:10001
      environment:
        spring.profiles.active: stgSlave

networks:
  mcd-local-bridge:
    external: true
```
## k8s 编排
```yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: eureka-registry-master
  labels:
    app: eureka-registry-master
spec:
  template:
    metadata:
      labels:
        app: eureka-registry-master
    spec:
      containers:
      - image: 192.168.1.181/ms_platform/eureka-cluster:1.0
        name: eureka-cluster
        env:
        - name: JAVA_OPTS
          value: -Xmx200m -Dspring.profiles.active=stgMaster
        ports:
        - containerPort: 30001
          name: http
---
apiVersion: v1
kind: Service
metadata:
  name: eureka-registry-master
spec:
  type: NodePort
  ports:
  - port: 30001
    nodePort: 30411
  selector:
    app: eureka-registry-master

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: eureka-registry-slave
  labels:
    app: eureka-registry-slave
spec:
  template:
    metadata:
      labels:
        app: eureka-registry-slave
    spec:
      containers:
      - image: 192.168.1.181/ms_platform/eureka-cluster:1.0
        name: eureka-cluster
        env:
        - name: JAVA_OPTS
          value: -Xmx200m -Dspring.profiles.active=stgSlave
        ports:
        - containerPort: 30002
          name: http
---
apiVersion: v1
kind: Service
metadata:
  name: eureka-registry-slave
spec:
  type: NodePort
  ports:
  - port: 30002
    nodePort: 30412
  selector:
    app: eureka-registry-slave
```