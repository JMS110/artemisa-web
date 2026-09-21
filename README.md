# Artemisa Web

Web comercial de [Artemisa Floristas](https://artemisafloristas.com), floristería en Torrevieja desde 1991.

## Tecnología

- Astro 7
- Tailwind CSS 4
- Español e inglés
- Despliegue automático en Vercel desde `main`

## Desarrollo

```sh
npm ci
npm run dev
npm run build
```

## Publicación de fotos

Los originales se suben al NAS en `/volume1/Web-Artemisa/<categoria>/`. El script descarga las fotos pendientes, genera WebP de hasta 1920 px, actualiza el catálogo y archiva los originales en `_procesadas/`.

```sh
./scripts/publicar-artemisa.sh --dry-run  # comprobar pendientes
./scripts/publicar-artemisa.sh --no-push  # preparar commit local
./scripts/publicar-artemisa.sh            # publicar en producción
```

El último comando hace `push` a `main` y activa el despliegue de producción. Debe confirmarse antes de ejecutarlo.

La documentación operativa completa está en `CLAUDE.md` y en la nota de Obsidian `Artemisa Web — flujo fotos.md`.
