# Artemisa Web — proyecto de JuanMa

Web comercial de **Artemisa Floristas** (Torrevieja), empresa de Rebeca (esposa de JuanMa), activa desde 1991.

## Stack

- **Astro 7** + **TailwindCSS 4** + i18n ES/EN
- Repo: `JMS110/artemisa-web` (GitHub)
- Deploy: **Vercel Hobby** con auto-deploy en push a `main`
- DNS DonDominio → Vercel

## SEO local

- Google Business Profile existente y gestionado por Rebeca; datos actualizados el 2026-09-21.
- SEO técnico desplegado en producción el 2026-09-21 (commit `ac61168`): metadatos por página, canonical/hreflang ES-EN, JSON-LD `Florist`, sitemap y robots.
- La página de contacto usa llamadas telefónicas y enlace a Google Maps; no hay formulario ni WhatsApp.
- Vercel y las rutas públicas verificados; siguiente paso: alta del dominio en Google Search Console y envío del sitemap.

## Reglas críticas

1. **NO editar `src/data/catalog.ts`** — es autogenerado por `scripts/publicar-artemisa.sh`
2. **NO editar imágenes en `public/images/`** — las regenera el script (WebP optimizado desde originales en NAS)
3. **Confirmar antes de push a `main`** — Vercel despliega automáticamente en producción

## Flujo de contenido

Fotos originales viven en el NAS (`/volume1/Web-Artemisa/<categoria>/`). Al ejecutar `./scripts/publicar-artemisa.sh` desde el Mac: descarga → optimiza WebP 1920px → copia al repo → commit + push → Vercel despliega.

Categorías visibles/NAS: `Ramos`, `Centros`, `Plantas`, `Flor seca y preservada`, `Eventos` y `Composiciones fúnebres`. Las fotos de bodas forman parte de `Eventos`.

Desde 2026-09-20, las 69 fotos históricas y la primera subida desde el iPhone están archivadas en `_procesadas/`; el repo contiene 70 WebP optimizados (unos 21 MB). UGREENOS bloquea `rsync` remoto sobre `/volume1`, por lo que el script transfiere mediante `tar` sobre SSH.

## Fuentes de verdad (leer antes de trabajar)

- **Vault Obsidian** (perfil general): `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second brain/_AI_ENTRYPOINT.md`
- **Playbook fotos**: `Second brain/Personal/Digital/Artemisa Web — flujo fotos.md`
- **CLAUDE.md** (detalle completo — datos negocio, comandos, decisiones): `./CLAUDE.md`
- **Datos negocio**: `./info-negocio.md`

## Comandos habituales

```bash
npm run dev                              # dev server localhost:4321
npm run build                            # build a ./dist/
./scripts/publicar-artemisa.sh           # publicar fotos NAS → Vercel
./scripts/publicar-artemisa.sh --dry-run # simular sin cambios
./scripts/publicar-artemisa.sh --catalog-only # regenerar solo catalog.ts desde los WebP locales
```

## Comportamiento esperado

- Trabajar siempre en **español**
- Confirmar antes de push
- No exponer teléfono personal de Rebeca en repo (usar el del negocio 633 501 113)
- WhatsApp no se ofrece como canal de la tienda; no añadir llamadas a la acción de WhatsApp.
- Al añadir features, actualizar CLAUDE.md

## Nota de portabilidad

Fichero leído por Cursor, Copilot, Codex, Gemini CLI, Aider, Windsurf, Zed. Claude Code lee CLAUDE.md.
