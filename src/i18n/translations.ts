export const languages = {
  es: 'Español',
  en: 'English',
};

export const defaultLang = 'es';

export const ui = {
  es: {
    'nav.home': 'Inicio',
    'nav.catalog': 'Catálogo',
    'nav.contact': 'Contacto',
    'hero.tagline': 'Floristería en Torrevieja desde 1991',
    'hero.subtitle': 'Desde 1991, formamos parte de los momentos que importan. Bodas, cumpleaños, despedidas, celebraciones… porque cada ocasión merece una flor.',
    'hero.cta': 'Ver catálogo',
    'catalog.title': 'Nuestro catálogo',
    'catalog.subtitle': 'Descubre nuestros arreglos florales',
    'catalog.ramos': 'Ramos',
    'catalog.centros': 'Centros',
    'catalog.coronas': 'Composiciones fúnebres',
    'catalog.plantas': 'Plantas',
    'catalog.bodas': 'Bodas',
    'catalog.eventos': 'Eventos',
    'catalog.florseca': 'Flor seca y preservada',
    'catalog.cta': '¿Tienes un encargo especial?',
    'catalog.cta.sub': 'Bodas, eventos, regalos… lo hacemos a medida.',
    'contact.title': 'Contacto',
    'contact.subtitle': '¿Tienes alguna pregunta o quieres hacer un pedido?',
    'contact.name': 'Nombre',
    'contact.email': 'Email',
    'contact.message': 'Mensaje',
    'contact.send': 'Enviar',
    'contact.phone': 'Teléfono',
    'contact.address': 'Dirección',
    'contact.hours': 'Horario',
    'contact.order.title': 'Haz tu encargo por teléfono',
    'contact.order.subtitle': 'Cuéntanos qué necesitas y te asesoramos personalmente.',
    'contact.call.landline': 'Llamar al 965 711 243',
    'contact.call.mobile': 'Llamar al 633 501 113',
    'contact.maps': 'Ver cómo llegar en Google Maps',
    'hours.weekdays': 'Lun – Vie: 10:00 – 13:30 / 17:00 – 20:00',
    'hours.saturday': 'Sáb: 10:00 – 13:30',
    'hours.summer': 'Verano: 10:00 – 13:30 / 17:30 – 20:30',
    'hours.sunday': 'Dom: Cerrado',
    'footer.rights': 'Todos los derechos reservados',
    'delivery': '🚚 Reparto en Torrevieja, La Mata y Orihuela Costa',
  },
  en: {
    'nav.home': 'Home',
    'nav.catalog': 'Catalogue',
    'nav.contact': 'Contact',
    'hero.tagline': 'Florist in Torrevieja since 1991',
    'hero.subtitle': 'Since 1991, we have been part of the moments that matter. Weddings, birthdays, farewells, celebrations… because every occasion deserves a flower.',
    'hero.cta': 'View catalogue',
    'catalog.title': 'Our catalogue',
    'catalog.subtitle': 'Discover our floral arrangements',
    'catalog.ramos': 'Bouquets',
    'catalog.centros': 'Centrepieces',
    'catalog.coronas': 'Funeral Arrangements',
    'catalog.plantas': 'Plants',
    'catalog.bodas': 'Weddings',
    'catalog.eventos': 'Events',
    'catalog.florseca': 'Dried & Preserved Flowers',
    'catalog.cta': 'Have a special request?',
    'catalog.cta.sub': 'Weddings, events, gifts… we make it to order.',
    'contact.title': 'Contact',
    'contact.subtitle': 'Do you have a question or want to place an order?',
    'contact.name': 'Name',
    'contact.email': 'Email',
    'contact.message': 'Message',
    'contact.send': 'Send',
    'contact.phone': 'Phone',
    'contact.address': 'Address',
    'contact.hours': 'Opening hours',
    'contact.order.title': 'Place your order by phone',
    'contact.order.subtitle': 'Tell us what you need and we will advise you personally.',
    'contact.call.landline': 'Call 965 711 243',
    'contact.call.mobile': 'Call 633 501 113',
    'contact.maps': 'Get directions on Google Maps',
    'hours.weekdays': 'Mon – Fri: 10:00 – 13:30 / 17:00 – 20:00',
    'hours.saturday': 'Sat: 10:00 – 13:30',
    'hours.summer': 'Summer: 10:00 – 13:30 / 17:30 – 20:30',
    'hours.sunday': 'Sun: Closed',
    'footer.rights': 'All rights reserved',
    'delivery': '🚚 Delivery in Torrevieja, La Mata and Orihuela Costa',
  },
} as const;

export type Lang = keyof typeof ui;
export type TranslationKey = keyof typeof ui[typeof defaultLang];

export function useTranslations(lang: Lang) {
  return function t(key: TranslationKey): string {
    return ui[lang][key] ?? ui[defaultLang][key];
  };
}

export function getLangFromUrl(url: URL): Lang {
  const [, lang] = url.pathname.split('/');
  if (lang in ui) return lang as Lang;
  return defaultLang;
}

export function getLocalizedPath(path: string, lang: Lang): string {
  if (lang === defaultLang) return path;
  return `/${lang}${path}`;
}
