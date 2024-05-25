CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL
);

INSERT INTO users (email, senha) VALUES ('kil.teste@inteli.com', '123');