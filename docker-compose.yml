mysql:
  image: mysql:5.7
  ports:
    - "8070:3306"  
  environment:
    - MYSQL_ROOT_PASSWORD=petclinic
    - MYSQL_DATABASE=petclinic
  volumes:
    - "./conf.d:/etc/mysql/conf.d:ro"
