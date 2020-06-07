FROM node:lts-alpine
ARG ALB_URL
RUN npm install -g http-server
WORKDIR /app
COPY package*.json ./
RUN yarn install
COPY . .
RUN echo 'VUE_APP_SERVER='$ALB_URL > .env
RUN yarn build

EXPOSE 80
CMD [ "http-server", "dist", "-p", "80" ]
# docker run -it -p 80:80 --rm --name app app