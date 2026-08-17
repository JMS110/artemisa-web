# Artemisa Web — proyecto de JuanMa

Web comercial de **Floristería Artemisa** (Torrevieja), empresa de Rebeca (esposa de JuanMa).

## Stack

- **Astro 6** + **TailwindCSS 4** + i18n ES/EN
- Repo: `JMS110/artemisa-web` (GitHub)
- Deploy: **Vercel Hobby** con auto-deploy en push a `main`
- DNS DonDominio → Vercel

## Reglas críticas

1. **NO editar `src/data/catalog.ts`** — es autogenerado por `scripts/publicar-artemisa.sh`
2. **NO editar imágenes en `public/images/`** — las regenera el script (WebP optimizado desde originales en NAS)
3. **Confirmar antes de push a `main`** — Vercel despliega automáticamente en producción

## Flujo de contenido

Fotos originales viven en el NAS (`/volume1/Web-Artemisa/<categoria>/`). Al ejecutar `./scripts/publicar-artemisa.sh` desde el Mac: descarga → optimiza WebP 1920px → copia al repo → commit + push → Vercel despliega.

Categorías: `ramos, centros, bodas, plantas, coronas, flor-seca, eventos`.

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
```

## Comportamiento esperado

- Trabajar siempre en **español**
- Confirmar antes de push
- No exponer teléfono personal de Rebeca en repo (usar el del negocio 633 501 113)
- Al añadir features, actualizar CLAUDE.md

## Nota de portabilidad

Fichero leído por Cursor, Copilot, Codex, Gemini CLI, Aider, Windsurf, Zed. Claude Code lee CLAUDE.md.
