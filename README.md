# Herkle Baritone

English / Русский

## Overview / Обзор

This project is a Roblox bot framework inspired by the architecture of Baritone-style pathing and automation. It provides modules for:

- configuration and state management
- world scanning and raycast checks
- grid/pathfinding logic
- target selection and validation
- movement controllers (walk/fly/anti-stuck/wall-follow)
- combat helpers
- safety and watchdog recovery
- runner orchestration and statistics

The current repository is structured as a modular toolkit for building a Roblox automation bot, and it is designed to be extended step by step.

Проект представляет собой фреймворк для бота в Roblox, вдохновленный архитектурой Baritone-style pathing и автоматизации. Он включает модули для:

- конфигурации и управления состоянием
- сканирования мира и проверки raycast
- логики сетки и поиска пути
- выбора цели и валидации
- контроллеров движения (ходьба/полёт/анти-залипание/обход стен)
- вспомогательных модулей для боя
- безопасности и восстановления после сбоев
- оркестрации раннера и статистики

Этот репозиторий организован как модульный набор инструментов для построения бота для Roblox и рассчитан на постепенное расширение.

---

## Project structure / Структура проекта

```text
src/
├── init.luau
├── Baritone.luau
├── Core/
│   ├── Config.luau
│   ├── Logger.luau
│   ├── Events.luau
│   ├── State.luau
│   ├── Scheduler.luau
│   └── Feature.luau
├── Util/
│   ├── Vector.luau
│   ├── Table.luau
│   ├── String.luau
│   ├── Time.luau
│   ├── Player.luau
│   ├── Entity.luau
│   ├── Retry.luau
│   ├── RateLimit.luau
│   ├── Signal.luau
│   └── Pool.luau
├── World/
│   ├── Raycast.luau
│   ├── Obstacle.luau
│   ├── Grid.luau
│   ├── Cache.luau
│   └── Terrain.luau
├── Math/
│   ├── AStar.luau
│   ├── Interpolation.luau
│   ├── Bezier.luau
│   └── Noise.luau
├── Target/
│   ├── Scanner.luau
│   ├── Filter.luau
│   ├── Blacklist.luau
│   ├── Tracker.luau
│   ├── Prioritizer.luau
│   └── Validator.luau
├── Movement/
│   ├── init.luau
│   ├── Walk.luau
│   ├── Fly.luau
│   ├── AntiStuck.luau
│   ├── PathFollow.luau
│   ├── Humanizer.luau
│   ├── Camera.luau
│   ├── WallFollow.luau
│   └── ...
├── Combat/
│   ├── Encoder.luau
│   ├── Cooldown.luau
│   ├── Swing.luau
│   └── Tool.luau
├── Safety/
│   ├── AntiAFK.luau
│   ├── Focus.luau
│   ├── Pattern.luau
│   └── Guard.luau
├── Runner/
│   ├── Runner.luau
│   ├── Stats.luau
│   ├── Recovery.luau
│   ├── Reporter.luau
│   └── Watchdog.luau
└── example.luau
```

---

## Quick start / Быстрый старт

### English

```lua
local BASE = "https://raw.githubusercontent.com/your-user/your-repo/main/src/"
local Baritone = loadstring(game:HttpGet(BASE .. "init.luau"))(BASE)

Baritone.SetPreset("balanced")
Baritone.SetConfig("SearchRange", 150)
Baritone.SetConfig("MoveMode", "Walk")
Baritone.Start()
```

### Русский

```lua
local BASE = "https://raw.githubusercontent.com/your-user/your-repo/main/src/"
local Baritone = loadstring(game:HttpGet(BASE .. "init.luau"))(BASE)

Baritone.SetPreset("balanced")
Baritone.SetConfig("SearchRange", 150)
Baritone.SetConfig("MoveMode", "Walk")
Baritone.Start()
```

---

## Main ideas / Основные идеи

### English

- The project is built around a modular pipeline: config -> scanner -> target -> movement -> runner.
- The `Runner` orchestrates the lifecycle and calls the movement and safety systems.
- `Config` acts as the central configuration object with validation.
- `Target` modules select targets and filter invalid choices.
- `Movement` covers walking, flying, jumping, wall-follow, and anti-stuck logic.
- `Safety` and `Watchdog` help recover from stalls or invalid states.

### Русский

- Проект построен вокруг модульного конвейера: config -> scanner -> target -> movement -> runner.
- `Runner` управляет жизненным циклом и вызывает системы движения и безопасности.
- `Config` является центральным объектом конфигурации с валидацией значений.
- Модули `Target` выбирают цели и фильтруют невалидные варианты.
- `Movement` покрывает ходьбу, полёт, прыжки, обход стен и анти-залипание.
- `Safety` и `Watchdog` помогают восстанавливаться после зависаний и некорректных состояний.

---

## Configuration / Конфигурация

The framework exposes a central configuration table with a validation layer.

Фреймворк предоставляет центральную таблицу конфигурации с уровнем валидации.

Examples / Примеры:

```lua
Baritone.SetConfig("MoveMode", "Walk")
Baritone.SetConfig("SearchRange", 200)
Baritone.SetConfig("FlySpeed", 30)
Baritone.SetConfig("DebugLogging", true)
```

Available presets / Доступные пресеты:

```lua
Baritone.SetPreset("safe")
Baritone.SetPreset("balanced")
Baritone.SetPreset("fast")
```

---

## Notes / Примечания

### English

This code is structured as a sturdy foundation for a Roblox automation bot. It was created to be extensible and easy to maintain, while still offering battle, movement, scanning, and safety logic in a single coherent framework.

The implementation intentionally avoids hard dependency on one narrow gameplay pattern, so it can be adapted to different Roblox experiences.

### Русский

Этот код организован как прочный каркас для бота в Roblox. Он создан так, чтобы быть расширяемым и легко поддерживаемым, при этом имея в одном согласованном фреймворке логику боя, движения, сканирования и безопасности.

Реализация сознательно избегает жёсткой привязки к одному узкому игровому паттерну, поэтому её можно адаптировать под разные Roblox-опыт.

---

## Important / Важно

### English

This project is still a framework skeleton and should be treated as a starting point for a real in-game automation system. Some modules are intentionally generic and can be extended according to your game mechanics.

### Русский

Этот проект всё ещё является каркасом фреймворка и должен рассматриваться как стартовая точка для реальной игровой автоматизации. Некоторые модули специально сделаны универсальными и могут быть расширены под вашу механику игры.

---

## License / Лицензия

This repo is intended for educational and custom project use. Please adapt and improve it according to your requirements.

Этот репозиторий предназначен для образовательного и кастомного использования. Настраивайте и улучшайте его под свои требования.
