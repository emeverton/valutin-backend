import { MedusaContainer } from "@medusajs/framework"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"

const CATEGORIES = [
  { name: "Bebê", handle: "bebe" },
  { name: "Criança", handle: "crianca" },
  { name: "Calçados", handle: "calcados" },
  { name: "Acessórios", handle: "acessorios" },
  { name: "Ocasiões", handle: "ocasioes" },
  { name: "Quarto", handle: "quarto" },
]

export default async function seedCategories({
  container,
}: {
  container: MedusaContainer
}) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const productModuleService = container.resolve(Modules.PRODUCT)

  logger.info("Seeding product categories...")

  const existing = await productModuleService.listProductCategories(
    { handle: CATEGORIES.map((c) => c.handle) },
    { select: ["handle"] }
  )
  const existingHandles = new Set(existing.map((c) => c.handle))

  const toCreate = CATEGORIES.filter((c) => !existingHandles.has(c.handle))

  if (toCreate.length === 0) {
    logger.info("All categories already exist, skipping.")
    return
  }

  await productModuleService.createProductCategories(
    toCreate.map((c) => ({ name: c.name, handle: c.handle, is_active: true }))
  )

  for (const c of toCreate) {
    logger.info(`Created category: ${c.name} (${c.handle})`)
  }

  logger.info("Finished seeding product categories.")
}
