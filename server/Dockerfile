# Compila o servidor em AOT e monta uma imagem mínima só com o binário,
# o runtime do Dart e o seed.json.
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/seed.json /app/seed.json

ENV SEED_FILE=/app/seed.json
ENV PORT=8080
EXPOSE 8080
CMD ["/app/bin/server"]
