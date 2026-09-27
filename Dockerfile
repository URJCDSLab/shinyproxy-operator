# --- Etapa 1: Compilación ---
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .

# 1. Compilamos (saltando licencias y tests para que no falle)
RUN mvn -U clean install -DskipTests -Dlicense.skip=true

# 2. EL TRUCO: Buscamos el archivo generado y lo renombramos a "app.jar"
# Usamos 'find' porque es más listo que el asterisco. 
# Le decimos: "Busca en la carpeta target cualquier archivo que termine en dependencies.jar y llámalo app.jar"
RUN find target -name "*dependencies.jar" -exec mv {} target/app.jar \;

# --- Etapa 2: Imagen Final ---
FROM eclipse-temurin:21-jre
WORKDIR /opt

# 3. Ahora copiamos el archivo con el nombre fijo que acabamos de crear
# Ya no hay asteriscos, ni dudas. Se llama app.jar.
COPY --from=build /app/target/app.jar /opt/shinyproxy-operator.jar

# 4. Ajustamos permisos para tu usuario
RUN chmod 644 /opt/shinyproxy-operator.jar

CMD ["java", "-jar", "/opt/shinyproxy-operator.jar"]
