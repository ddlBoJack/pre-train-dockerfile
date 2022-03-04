docker build -t speechimage .
docker tag speechimage:latest chenxie95/speechimage:latest
docker push chenxie95/speechimage:latest
docker run -it --runtime=nvidia --name speechimage \
    --mount src=/mnt/xlancefs/home/chenxie95/data,target=/data/chenxie95,type=bind \
    --mount src=/mnt/xlancefs/home/xc095/data,target=/data/xc095,type=bind \
    -v /mnt/xlancefs/home/chenxie95:/home/chenxie95 \
    -p 12345:22 \
    --ipc=host
    chenxie95/speechimage:latest /bin/bash


# debug and commit docker image
sudo nvidia-docker run -it --name test speechimage:latest
docker commit <container_id> <image_name:tag>
docker commit a98ee6e97b84 chenxie95/pre-train:latest
