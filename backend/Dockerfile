# Use official Node image
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Expose backend port
EXPOSE 5000

CMD ["npm", "start:prod"]
