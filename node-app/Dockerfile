FROM node:lts

# Para para p projeto em node
WORKDIR /usr/src/app

# Copia arquivos package.json/package-lock.json para instalação de dependencias 
COPY package*.json ./

# Instalação do pm2 para gerenciamento dos processo do node
RUN npm install -g pm2

# Instalação de dependencias
RUN npm install

# Copia arquivos do projeto
COPY . .

EXPOSE 3000

# Inicia o gerenciador pm2
CMD [ "pm2", "start",  "--no-daemon", "processes.json" ]
