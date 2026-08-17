# Artemisa Web — proyecto de JuanMa

Web comercial de la **Floristería Artemisa** (Torrevieja, empresa de Rebeca, esposa de JuanMa). Trabaja siempre en español.

## Datos del negocio

- **Nombre**: Floristería Artemisa
- **Dirección**: Calle Zoa, 55 (esquina C/ Antonio Machado), 03180 Torrevieja, Alicante
- **Teléfono**: 965 711 243
- **Móvil / WhatsApp**: 633 501 113
- **Web**: https://artemisafloristas.com
- **Horarios**:
  - Temporada normal: 10:00 – 13:30 / 17:00 – 20:00
  - Verano tardes: 17:00 – 20:30
  - Sábados: 10:00 – 13:30
  - Domingos: cerrado

## Stack

- **Astro 6** + **TailwindCSS 4** + i18n (ES / EN, defaultLocale `es`, `prefixDefaultLocale: false`)
- **Repo GitHub**: `JMS110/artemisa-web`
- **Deploy**: **Vercel Hobby** con auto-deploy en cada push a `main`
- **DNS**: DonDominio → Vercel (IP `76.76.21.21`)
- **Node**: `>=22.12.0`

## Estructura del código

```
src/
├── components/  (Nav.astro, Footer.astro)
├── data/catalog.ts   ← AUTOGENERADO por scripts/publicar-artemisa.sh
├── i18n/translations.ts
├── layouts/Layout.astro
├── pages/
│   ├── index.astro
│   ├── catalogo.astro
│   ├── contacto.astro
│   ├── catalogo/[categoria].astro
│   └── en/ (versión inglesa)
└── styles/global.css
public/
└── images/
    ├── ramos/       (WebP optimizado)
    ├── centros/
    ├── bodas/
    ├── plantas/
    ├── coronas/
    ├── flor-seca/
    └── eventos/
```

## Categorías del catálogo

`ramos`, `centros`, `bodas`, `plantas`, `coronas`, `flor-seca` (era `florseca`, cambiado por legibilidad), `eventos`

## Flujo de fotos — NAS master

**Producción (2026-08-09 en adelante)**:

```
📱 Rebeca hace foto → iPhone → Files.app
     ↓ (subida SMB a NAS, vía Tailscale)
🗄  NAS: /volume1/Web-Artemisa/<categoria>/
     ↓ (cuando JuanMa quiera publicar)
💻 JuanMa ejecuta desde Mac: ./scripts/publicar-artemisa.sh
     - rsync NAS → tmp local
     - resize 1920px max + WebP q82 (con sips + cwebp)
     - copia a public/images/<categoria>/
     - mueve originales en NAS → _procesadas/
     - regenera src/data/catalog.ts
     - git commit + push
     ↓
🐙 GitHub webhook → ▲ Vercel build automático
```

**Nunca** editar `src/data/catalog.ts` a mano — es autogenerado.

## Comandos

```bash
npm install       # dependencias
npm run dev       # dev server localhost:4321
npm run build     # build a ./dist/
npm run preview   # preview del build
./scripts/publicar-artemisa.sh              # flujo completo (sync + optimize + commit + push)
./scripts/publicar-artemisa.sh --dry-run    # simular sin cambios
./scripts/publicar-artemisa.sh --no-push    # commit local sin push
```

## Fuentes de verdad (leer antes de trabajar)

- **Vault Obsidian** (perfil general): `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second brain/_AI_ENTRYPOINT.md`
- **Playbook fotos**: `Second brain/Personal/Digital/Artemisa Web — flujo fotos.md`
- **Datos del negocio**: `./info-negocio.md`

## Decisiones cerradas

- **Fotos en NAS, no iCloud** (migración 2026-08-09). El plan era hacerlo el domingo 9 con Rebeca — verificar estado real de la migración antes de tocar.
- **Vercel Hobby** (no self-host): la web es comercial y no debe depender de la conexión O2 de casa. NAS solo sirve como master de fotos originales.
- **Deuda técnica conocida**: fotos originales ~196 MB (antes de optimización). Al primer error de límite Vercel Hobby → revisar `public/images/` en el repo.

## Pendientes conocidos

- Email `contacto@artemisafloristas.com` o similar en mailbox.org (pendiente)
- Instagram / Facebook oficiales (pendientes)
- Google My Business (SEO local, muy importante para floristería)
- WhatsApp Business con link `wa.me/34633501113` desde la web

## Comportamiento esperado

- Confirmar antes de push a `main` (Vercel despliega automáticamente)
- No tocar `src/data/catalog.ts` manualmente
- No editar imágenes en `public/images/` — el script las regenera
- Al añadir features o cambiar convenciones, actualizar este CLAUDE.md
