CREATE DATABASE desafio3_rodrigo_paz_358;

CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  email VARCHAR(50),
  nombre VARCHAR(20),
  apellido VARCHAR(20),
  rol VARCHAR(20) CHECK (rol IN ('administrador', 'usuario'))
);

INSERT INTO
  usuarios (email, nombre, apellido, rol)
VALUES
  (
    'juan.perez@gmail.com',
    'Juan',
    'Perez',
    'administrador'
  ),
  (
    'maria.garcia@gmail.com',
    'Maria',
    'Garcia',
    'usuario'
  ),
  (
    'carlos.lopez@gmail.com',
    'Carlos',
    'Lopez',
    'usuario'
  ),
  (
    'ana.martinez@gmail.com',
    'Ana',
    'Martinez',
    'usuario'
  ),
  (
    'luis.rodriguez@gmail.com',
    'Luis',
    'Rodriguez',
    'administrador'
  );

CREATE TABLE post (
  id SERIAL PRIMARY KEY,
  titulo VARCHAR(100),
  contenido TEXT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  destacado BOOLEAN DEFAULT FALSE,
  usuario_id BIGINT REFERENCES usuarios(id)
);

INSERT INTO
  post (
    titulo,
    contenido,
    fecha_creacion,
    fecha_actualizacion,
    destacado,
    usuario_id
  )
VALUES
  (
    'Introducción a PostgreSQL',
    'En este post, aprenderemos los conceptos básicos de PostgreSQL.',
    '2024-07-10 10:00:00',
    '2024-07-10 10:00:00',
    FALSE,
    1
  ),
  (
    'Mejorando el rendimiento de consultas',
    'Aquí hay algunas estrategias para optimizar consultas en PostgreSQL.',
    '2024-07-11 11:30:00',
    '2024-07-11 11:30:00',
    TRUE,
    2
  ),
  (
    'Guía de índices en PostgreSQL',
    'Los índices son cruciales para mejorar el rendimiento de las consultas.',
    '2024-07-12 09:15:00',
    '2024-07-12 09:15:00',
    FALSE,
    3
  ),
  (
    'Uso de transacciones',
    'Las transacciones aseguran la integridad de los datos en PostgreSQL.',
    '2024-07-13 14:45:00',
    '2024-07-13 14:45:00',
    FALSE,
    1
  ),
  (
    'Funciones y procedimientos almacenados',
    'Las funciones son útiles para encapsular lógica de negocio en la base de datos.',
    '2024-07-14 16:00:00',
    '2024-07-14 16:00:00',
    TRUE,
    5
  );

CREATE TABLE comentarios (
  id SERIAL,
  contenido TEXT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usuario_id BIGINT REFERENCES usuarios(id),
  post_id BIGINT REFERENCES post(id)
);

INSERT INTO
  comentarios (contenido, fecha_creacion, usuario_id, post_id)
VALUES
  (
    'Este es el primer comentario.',
    '2024-07-14 12:34:56',
    1,
    1
  ),
  (
    'Estoy de acuerdo con el primer comentario.',
    '2024-07-14 12:45:23',
    2,
    1
  ),
  (
    'Muy interesante punto de vista.',
    '2024-07-14 13:00:00',
    3,
    1
  ),
  (
    'Gran post, aprendí mucho.',
    '2024-07-14 14:15:45',
    1,
    2
  ),
  (
    'Gracias por la información.',
    '2024-07-14 14:30:00',
    5,
    2
  );

-- Requerimientos rubrica
-- 1. Las consultas para completar el setup de acuerdo a lo pedido.
-- 2. Nombre y email del usuario junto al título y contenido del post.
SELECT
  u.nombre,
  u.email,
  p.titulo,
  p.contenido
FROM
  usuarios AS u
  INNER JOIN post AS p ON u.id = p.usuario_id;

-- 3. id, título y contenido de los posts de los administradores.
SELECT
  p.id,
  p.titulo,
  p.contenido
FROM
  post AS p
  INNER JOIN usuarios AS u ON p.usuario_id = u.id
WHERE
  rol = 'administrador';

-- 4. id, email y cantidad de posts de cada usuario.
SELECT
  u.id,
  u.email,
  COUNT(p.id) AS post_por_usuario
FROM
  usuarios AS u
  LEFT JOIN post AS p ON u.id = p.usuario_id
GROUP BY
  u.id,
  u.email;

-- 5. email del usuario que ha creado más posts.
SELECT
  u.email
FROM
  usuarios AS u
  INNER JOIN post As p ON u.id = p.usuario_id
GROUP BY
  u.id,
  u.email
ORDER BY
  COUNT(p.id) DESC
LIMIT
  1;

-- 6. Fecha del último post de cada usuario.
SELECT
  u.id,
  u.email,
  MAX(p.fecha_creacion) AS fecha_ultimo_post
FROM
  usuarios AS u
  LEFT JOIN post AS p ON u.id = p.usuario_id
GROUP BY
  u.id,
  u.email;

-- 7. Título y contenido del post con más comentarios
SELECT
  p.titulo,
  p.contenido,
  COUNT(c.id) AS cantidad_comentarios
FROM
  post AS p
  JOIN comentarios AS c ON p.id = c.post_id
GROUP BY
  p.id,
  p.titulo,
  p.contenido
HAVING
  COUNT(c.id) = (
    SELECT
      MAX(sub.cantidad_comentarios)
    FROM
      (
        SELECT
          COUNT(c.id) AS cantidad_comentarios
        FROM
          post AS p
          JOIN comentarios AS c ON p.id = c.post_id
        GROUP BY
          p.id
      ) sub
  );

--  8. Título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió.
SELECT
  p.titulo AS titulo_post,
  p.contenido AS contenido_post,
  c.contenido AS contenido_comentario,
  u.email AS email_usuario
FROM
  post AS p
  LEFT JOIN comentarios AS c ON p.id = c.post_id
  LEFT JOIN usuarios AS u ON c.usuario_id = u.id
ORDER BY
  p.id,
  c.id;

-- 9. Contenido del último comentario de cada usuario.
SELECT
  u.id,
  u.email,
  c.contenido AS contenido_del_ultimo_comentario
FROM
  usuarios AS u
  JOIN comentarios AS c ON u.id = c.usuario_id
WHERE
  c.fecha_creacion = (
    SELECT
      MAX(sub_c.fecha_creacion)
    FROM
      comentarios sub_c
    WHERE
      sub_c.usuario_id = u.id
  )
ORDER BY
  u.id;

-- 10. emails de los usuarios que no han escrito ningún comentario.
SELECT
  u.email
FROM
  usuarios AS u
  LEFT JOIN comentarios AS c ON u.id = c.usuario_id
WHERE
  c.id IS NULL;