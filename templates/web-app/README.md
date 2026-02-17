# {{PROJECT_NAME}}

Web application built with Vite, React, and TypeScript.

Created: {{DATE}}  
Author: {{AUTHOR}}

## Tech Stack

- **Build Tool:** [Vite](https://vitejs.dev/) - Fast dev server and optimized builds
- **Frontend:** [React](https://react.dev/) - UI library
- **Language:** [TypeScript](https://www.typescriptlang.org/) - Type-safe JavaScript
- **Package Manager:** npm

## Development

```bash
# Install dependencies
npm install

# Start dev server
npm run dev
```

The dev server will start at `http://localhost:5173` by default.

## Build

```bash
# Build for production
npm run build

# Preview production build locally
npm run preview
```

Production files are output to the `dist/` directory.

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run lint` - Run linter (when configured)

## Project Structure

```
├── public/          # Static assets
├── src/
│   ├── main.tsx     # Application entry point
│   ├── App.tsx      # Root component
│   └── ...          # Add your components here
├── index.html       # HTML entry point
├── vite.config.ts   # Vite configuration
├── tsconfig.json    # TypeScript configuration
└── package.json     # Dependencies and scripts
```

## Next Steps

1. Add your components to `src/`
2. Configure linting (ESLint) and formatting (Prettier) as needed
3. Add routing with React Router if building a multi-page app
4. Set up testing with Vitest or Jest
5. Configure CI/CD for automated deployments
