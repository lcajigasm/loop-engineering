# TODO — mejoras inspiradas en Keelcode

Revisión: 2026-07-29. Keelcode presenta un plan por fases, riesgo/alcance/
alternativas antes de editar, evidencia navegable de cada ejecución, agentes
paralelos y relanzamiento al recibir cambios. La skill ya cubre bucles
verificados, presupuestos, recibos, estado y planificación de paralelismo;
estos ítems solo cubren las diferencias útiles en un flujo local.

## Prioridad alta

- [x] Añadir un artefacto mínimo `docs/plans/<goal-id>.md`, creado antes de
  `goal`/`auto`, con: alcance, archivos previstos, fases, riesgos, alternativas
  descartadas y comando `VERIFY`. Pedir confirmación solo si el riesgo o el
  alcance cambian; enlazarlo desde el recibo. Esto materializa la visibilidad
  previa de Keelcode sin inventar una UI.
- [x] Ampliar el recibo con evidencia reproducible: revisión de git, archivos
  modificados, comando de verificación, salida final (o ruta a un log) y
  commit/HEAD. `status` debe señalar recibos sin esa evidencia.
- [x] Introducir una comprobación de alcance antes de cerrar un objetivo:
  comparar `git diff --name-only` con `Scope`; si salen archivos ajenos,
  exigir que se justifiquen en el plan o se separen en otro objetivo. Evita
  que una iteración verde esconda expansión de alcance.

## Prioridad media

- [x] Extender `parallel` con un manifiesto de integración: para cada objetivo,
  rama/worktree, archivos solapados detectados, orden de integración y el
  `VERIFY` que se ejecutará tras cada merge. Mantener Codex en modo secuencial
  si no hay worktrees gestionados.
- [x] Añadir `watch` como modo explícito y acotado: observar la rama durante
  un presupuesto de tiempo y, ante nuevos commits, ejecutar el `VERIFY` del
  objetivo afectado y registrar el resultado. Debe detenerse al agotar el
  presupuesto o ante tres fallos iguales; no implementar un daemon ni un
  servicio remoto.
- [x] Añadir una fase de descubrimiento de capacidades al `start`: listar
  skills, MCPs, hooks y CI ya disponibles, y registrar solo los que afectan
  al plan o a la verificación. Así el plan aprovecha herramientas del repo
  sin acoplarse a proveedores concretos.

## Prioridad baja

- [x] Añadir un comando `review <goal-id>` de solo lectura: mostrar en una
  salida compacta el plan, diff, evidencia de `VERIFY`, riesgos aceptados y
  cuestiones abiertas. Es el equivalente local de una entrega lista para
  revisión, sin crear PR ni exigir GitHub.
- [x] Definir una política opcional de revalidación tras cambios externos:
  cuando un commit posterior toque el `Scope` de un objetivo pasado, marcar
  su evidencia como "requiere revalidación" en `STATUS.md`; no relanzar el
  loop automáticamente sin un presupuesto nuevo.

## Deliberadamente fuera de alcance

- Dashboard alojado, cuentas, créditos, modelos gestionados e integraciones
  SaaS: pertenecen al producto de Keelcode, no a una skill portable local.
- Relanzamiento automático en cada push: solo añadirlo si el usuario aporta
  CI y una política explícita de coste/tiempo; el modo `watch` cubre el caso
  local sin procesos persistentes.

Fuentes: [Keelcode](https://keelcode.ai/) y
[documentación de la CLI](https://keelcode.ai/docs/cli/usage).
