.cursor/rules/project-rules.md

# Professional React / Next.js Website Rules

## Project Goal

Build a professional, production-quality website.

The website should feel polished, modern, and comparable to established gaming community websites.

Prioritise:

- Clean design
- Excellent user experience
- Performance
- Accessibility
- Maintainable code
- Responsive layouts
- SEO optimisation

The website should not feel like a generic template.

---

# Development Principles

- Write clean, readable, maintainable production-quality code.
- Prefer simple solutions over unnecessary complexity.
- Explain major architectural decisions before implementing them.
- Do not introduce dependencies unless there is a clear benefit.
- Avoid over-engineering.
- Keep existing functionality working when making changes.
- Do not rewrite working code without a clear reason.

Before making major changes:

1. Explain the approach.
2. Explain affected files.
3. Explain any dependencies required.
4. Explain potential side effects.

---

# React Requirements

- Use functional components only.
- Use React hooks appropriately.
- Keep components small and focused.
- Create reusable components wherever possible.
- Avoid duplicated markup.
- Use props and data-driven rendering.

Common reusable components should include:

- Navigation
- Header
- Footer
- GuildCard
- MemberCard
- EventCard
- NewsCard
- Buttons
- Forms
- Modals

Components should be reusable and accept data through props.

Avoid creating large components containing unrelated functionality.

---

# Next.js Requirements

- Use Next.js with the App Router.
- Use server components by default.
- Only use client components when interactivity requires them.
- Keep routing clean and logical.
- Optimise pages for performance and SEO.
- Use Next.js recommended patterns.

Use:

- Server-side rendering where appropriate.
- Static generation where appropriate.
- Next.js Image optimisation.
- Metadata API for SEO.

---

# Project Structure

Maintain a clean, professional project structure.

```text
/
├── app/
│   ├── page.tsx
│   ├── guilds/
│   ├── members/
│   ├── events/
│   └── news/
│
├── components/
│   ├── ui/
│   ├── layout/
│   ├── GuildCard/
│   ├── MemberCard/
│   ├── EventCard/
│   ├── Navigation/
│   └── Footer/
│
├── hooks/
├── lib/
├── public/
├── sanity/
│   ├── schemas/
│   ├── client.ts
│   ├── queries.ts
│   └── sanity.config.ts
│
├── styles/
├── types/
└── package.json
```

Keep:

- Business logic separate from UI components.
- API logic separate from presentation.
- CMS logic separate from frontend components.
- Components focused on a single responsibility.
- Folder names clear and consistent.

---

# Styling Requirements

Use modern CSS practices.

Preferred:

- CSS Modules
- Organised global styles
- CSS variables
- Flexbox
- CSS Grid

Avoid:

- Excessive inline styles.
- Fixed-width layouts.
- Poorly structured CSS.
- Repeated styling.

---

# Responsive Design Requirements

The primary design target is desktop.

Build using a desktop-first approach.

The website must provide a high-quality experience on:

- Desktop monitors
- Laptops
- Tablets
- Mobile phones

Desktop should provide the full visual experience:

- Rich layouts
- Detailed artwork
- Multi-column sections
- Advanced navigation

Tablet and mobile layouts should adapt intelligently:

- Stack columns where required.
- Provide mobile-friendly navigation.
- Maintain readable text sizes.
- Ensure buttons are touch-friendly.
- Optimise images for smaller screens.

Avoid:

- Desktop layouts simply shrinking onto mobile.
- Horizontal scrolling.
- Tiny controls.
- Unusable touch interfaces.

---

# UI / UX Requirements

The website should feel premium.

Include:

- Consistent spacing system.
- Consistent typography.
- Clear visual hierarchy.
- Hover states.
- Smooth transitions.
- Loading states.
- Error states.
- Empty states.

Animations should be:

- Smooth.
- Subtle.
- Professional.

Avoid:

- Excessive animations.
- Distracting effects.
- Generic gaming website styling.

---

# Gaming Theme / Brand Identity

The website should have a premium fantasy MMO aesthetic.

Design inspiration:

- Guild Wars style fantasy interfaces.
- Dark elegant backgrounds.
- Gold accents.
- Detailed borders.
- High-quality artwork.
- Professional gaming community feel.

Avoid:

- Generic gaming templates.
- Overused neon gaming styles.
- Low-quality effects.

Primary brand identity:

- Blood Gods
- Blood Gods Alliance
- Guild Wars Alliance

Maintain consistent branding across:

- Page titles.
- Headings.
- Metadata.
- Images.
- Social sharing information.

---

# Content Management System (Sanity)

Use Sanity CMS as the content management system.

Sanity should be configured from the beginning.

Include:

- Sanity Studio.
- Sanity client configuration.
- Environment variables.
- Content schemas.
- GROQ queries.
- Image handling.

Organise Sanity like this:

```text
sanity/
├── schemas/
│   ├── guild.ts
│   ├── member.ts
│   ├── event.ts
│   ├── news.ts
│   ├── page.ts
│   └── index.ts
│
├── client.ts
├── queries.ts
└── sanity.config.ts
```

Content that changes regularly should come from Sanity.

Do not hard-code:

- News articles.
- Guild information.
- Events.
- Recruitment posts.
- Announcements.
- Images.
- Alliance updates.

Create reusable Sanity schemas for:

- Guild
- Member
- Event
- News Article
- Page Content

---

# Data Handling

Do not hard-code repeated information.

Use structured data.

Example:

Instead of manually creating:

GuildCard GuildCard GuildCard

Use:

guilds = [ { name: "", leader: "", members: "", focus: "" } ]

Then render components dynamically.

---

# SEO Requirements

Every public page must be optimised for search engines.

Include:

- Unique page titles.
- Unique meta descriptions.
- Open Graph metadata.
- Social sharing images.
- Twitter/X card metadata.
- Canonical URLs.
- Proper heading structure.
- Semantic HTML.

Do not use duplicate metadata across pages.

Generate metadata dynamically from Sanity where appropriate.

Target relevant search terms naturally, including:

- Blood Gods Alliance
- Guild Wars Alliance
- Guild Wars community
- Alliance recruitment
- Guild Wars events

Do not keyword stuff.

Prioritise useful content.

---

# Structured Data Requirements

Implement Schema.org structured data where appropriate.

Include:

- Organisation schema.
- Website schema.
- Article schema for news.
- Event schema for events.

Ensure search engines understand:

- Alliance name.
- Community type.
- Events.
- News.
- Social profiles.

---

# Authentication Requirements

When implementing authentication:

- Use industry-standard authentication methods.
- Prefer OAuth providers.
- Do not create custom password systems.
- Keep authentication logic separate from UI.

Support:

- Logged-out users.
- Logged-in users.
- Unauthorised users.

---

# Discord Integration Requirements

The website should support Discord authentication.

Expected flow:

User | Login with Discord | Discord OAuth | Check Discord membership | Grant appropriate access

Access levels:

Public:

- Homepage.
- Alliance information.
- Recruitment.
- Public news.

Discord members:

- Private announcements.
- Internal resources.
- Event signups.

Officers/Admin:

- Manage guilds.
- Manage members.
- Publish news.
- Manage events.

---

# Security Requirements

Never expose:

- API keys.
- Secrets.
- Tokens.
- Database credentials.

Always:

- Validate user input.
- Protect sensitive routes.
- Follow secure authentication practices.

---

# Performance Requirements

Prioritise fast loading.

Use:

- Optimised images.
- Next.js Image component.
- Lazy loading where appropriate.
- Server components where possible.

Avoid:

- Large unnecessary dependencies.
- Heavy animations.
- Unoptimised media.

---

# Documentation Requirements

Explain:

- What each folder does.
- What each major component does.
- How data flows through the application.
- Why important technology choices were made.

The goal is not only to create code, but to maintain an understandable project.

---

# AI Behaviour

Act as a senior full-stack software engineer and UI/UX designer.

When responding:

- Think before coding.
- Challenge poor architectural decisions and explain why.
- Recommend best practices where appropriate.
- Explain trade-offs when multiple solutions exist.
- Never blindly implement a request if there is a significantly better approach.
- Prefer maintainable, scalable solutions.
- Produce code suitable for production rather than demonstrations.
- Keep responses concise unless more detail is requested.

---

# Avoid

Do not:

- Create unnecessary abstractions.
- Add libraries for simple tasks.
- Generate huge components.
- Rewrite working code without reason.
- Create desktop-only designs.
- Ignore accessibility.
- Ignore SEO.
- Hard-code content that belongs in the CMS.

---

# Naming Conventions

Follow consistent naming conventions throughout the project.

## Files

Use descriptive names.

Examples:
```text
components/
├── GuildCard.tsx
├── MemberCard.tsx
├── EventCard.tsx
├── HeroBanner.tsx
├── Navigation.tsx
```
Avoid:

- component.tsx
- newComponent.tsx
- temp.tsx
- test.tsx

## React Components

- Use PascalCase.
- Components should describe what they represent.

Examples:

GuildCard
MemberCard
HeroBanner
NavigationMenu

## Functions

Use camelCase.

Examples:

getGuilds()
fetchNews()
validateUser()
calculateRank()

Functions should begin with a verb whenever possible.

## Variables

Use camelCase.

Use descriptive names.

Good:

guildCount
currentUser
selectedGuild
eventDate

Avoid:

data
obj
temp
x
test

## Constants

Use UPPER_SNAKE_CASE.

Examples:

MAX_GUILD_SIZE
DEFAULT_THEME
API_TIMEOUT

## CSS

Use kebab-case for class names.

Examples:

.guild-card
.member-card
.hero-banner

Avoid generic names like:

.box
.container1
.left

Use names based on purpose, not appearance.

## Images

Use lowercase with hyphens.

Examples:

blood-gods-logo.png
guild-banner.webp
hero-background.webp

Avoid:

image1.png
logo-final-new.png

## Pages

Keep page names simple and descriptive.

Examples:

/guilds
/members
/events
/recruitment
/news

Avoid abbreviations unless universally understood.

## Sanity Schemas

Use singular names.

Examples:

guild
member
event
newsArticle

## Git Commits

Use clear commit messages.

Good:

Add guild recruitment page
Implement Discord authentication
Improve mobile navigation
Fix event calendar layout

Avoid:

Update
Changes
Fixed stuff

---

# Consistency

When adding new code:

- Follow the existing project structure.
- Match the existing naming conventions.
- Match the existing formatting style.
- Reuse existing components before creating new ones.
- Prefer extending existing functionality over duplicating it.

If multiple files solve the same problem, recommend refactoring instead of creating another implementation.

---

# Code Quality

Write code that is easy for an intermediate developer to understand.

Avoid unnecessarily clever or overly condensed solutions.

Prioritise readability over brevity.

Where a piece of logic is not immediately obvious, add a short comment explaining *why* it exists (not just what it does).