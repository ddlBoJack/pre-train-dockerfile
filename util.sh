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
