docker build -t pre-train .
docker tag pre-train:latest zym22/pre-train:latest
docker push zym22/pre-train:latest
docker run -it --runtime=nvidia --name pre-train \
    --mount src=/mnt/xlancefs/home/zym22/data,target=/data/zym22,type=bind \
    --mount src=/mnt/xlancefs/home/xc095/data,target=/data/xc095,type=bind \
    zym22/pre-train bash