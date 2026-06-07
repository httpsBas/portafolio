import { withBasePath } from "@/lib/base-path";
import { Link } from "@/types";

const links: Link[] = [
  {
    title: 'Home',
    href: '/',
    thumbnail: withBasePath('/assets/nav-link-previews/landing.png')
  },
  {
    title: 'About',
    href: '/#about',
    thumbnail: withBasePath('/assets/nav-link-previews/about.png')
  },
  {
    title: 'Skills',
    href: '/#skills',
    thumbnail: withBasePath('/assets/nav-link-previews/skills.png')
  },
  {
    title: 'Projects',
    href: '/#projects',
    thumbnail: withBasePath('/assets/nav-link-previews/projects.png')
  },
  // {
  //   title: 'Skills',
  //   href: '/skills',
  //   thumbnail: '/assets/nav-link-previews/skills.png'
  // },
  // {
  //   title: 'Testimonials',
  //   href: '/testimonials',
  //   thumbnail: '/assets/nav-link-previews/testimonials.png'
  // },
  {
    title: 'Blogs',
    href: '/blogs',
    thumbnail: withBasePath('/assets/nav-link-previews/blog.png'),
  },
  {
    title: 'Contact',
    href: '/#contact',
    thumbnail: withBasePath('/assets/nav-link-previews/contact.png')
  }
];

export { links };
