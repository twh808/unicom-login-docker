docker run -d \
  --name unicom-login \
  -p 5702:5702 \
  --restart unless-stopped \
  twh808/unicom-login:latest
