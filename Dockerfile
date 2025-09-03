# 1) Build
FROM node:20-alpine AS build
WORKDIR /app
# بعض مشاريع Next تحتاج libc6-compat على Alpine (لمكتبات مثل sharp)
RUN apk add --no-cache libc6-compat
COPY package*.json ./
RUN npm ci
COPY . .
# لا نمرّر أي NEXT_PUBLIC_API_BASE هنا
RUN npm run build

# 2) Runtime (standalone)
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
# إخراج Next.js بنمط standalone
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/public ./public
COPY --from=build /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node",".next/standalone/server.js"]
