/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        industrial: {
          50: '#f4f6f9',
          100: '#e5e9f0',
          200: '#cbd5e1',
          500: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        },
        navy: {
          800: '#111c38',
          900: '#0b132b',
        },
        brand: {
          blue: '#1d4ed8',
          lightBlue: '#3b82f6',
          teal: '#0d9488',
          green: '#10b981',
          accent: '#0284c7'
        }
      }
    },
  },
  plugins: [],
}
