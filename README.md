# Aura Creation and Configuration Guide

## 1. Organizing Aura Models by Tiers

* Decide on a **name** for your Aura model.
* Place the Aura model inside the `Tiers` folder located in `ServerStorage`.
* The `Tiers` folder is used to categorize Auras by rarity (e.g., Common, Rare, Legendary).

**Example folder structure:**

```
ServerStorage
 └── Tiers
     └── Common
         └── MyAura
```

---

## 2. Adding Animations

* If the Aura uses animations, create a folder named **Animations** inside the Aura model.
* Insert all relevant `Animation` objects into that folder.

---

## 3. Attaching Visual Effects to Parts

* Apply particle effects, beams, or other visuals to the **Torso-related parts** of the Aura model.
* It is not necessary to cover all torso parts.

  * Example: a **Common Aura** usually uses only `Torso` and `Head`.
  * More advanced or rare Auras may include arms, legs, and other parts.

---

## 4. Cleaning Up Attachments and Assets

* Delete any **unnecessary Attachments** that are not used.
* Remove extra meshes such as those on **Shirts, Accessories, Faces, and Hair**.
* Keeping the Aura model clean and minimal will prevent conflicts and reduce performance issues.

---

## 5. Configuring Collision and Mass Properties

To ensure the Aura does not interfere with character movement, disable collision and mass for all parts:

1. Open the **Command Bar** (from the top menu: `View` → `Command Bar`).
2. Select the Aura model in the Explorer.
3. Paste and run the following code:

```lua
for _, v in ipairs(game.Selection:Get()[1]:GetDescendants()) do
    if v:IsA("BasePart") then
        v.CanQuery = false
        v.CanCollide = false
        v.Massless = true
    end
end
```

**Result:**

* Aura parts will not collide with anything.
* Aura parts will be massless, ensuring smooth character movement.

---

## 6. Configuring Aura Equipping

* Go to `ServerScriptService` and open the `EquipScript`.
* In the **Attributes** section, set the `AuraName` attribute to the exact name of your Aura model.

**Example:**

* Aura model name: `"MyAura"`
* EquipScript → Attribute `AuraName`: `"MyAura"`

If the names do not match, the Aura will not equip correctly.

---

## 7. Advanced Features and Troubleshooting

* The Aura equipping system includes additional features not fully covered in this basic guide.
* Examples: rare Aura conditions, advanced animation blending, and effect triggers.
* If you encounter issues:

  1. First check that **`AuraName` matches the model name**.
  2. Ensure your Aura parts are properly attached using **Motor6D**.

---

# QnA

### Q1. **How do I run commands in Studio?**

* From the top menu, open `View` → `Command Bar`. Paste the code and press Enter.
* In the new Studio UI: `Window` → `Script` → `Commands`.

---

### Q2. **Why doesn’t my Aura model follow the character?**

* You need to connect the Aura parts to the **HumanoidRootPart** using **Motor6D**.
* Adjust the `C0` or `C1` properties of the Motor6D to set the correct offset.
* Alternatively, use a script to move the Aura part by setting its CFrame relative to the HumanoidRootPart:

  ```
  AuraPart.CFrame = HumanoidRootPart.CFrame * Offset
  ```

---

### Q3. **Do I have to match the AuraName exactly?**

* Yes. The `AuraName` attribute in `EquipScript` must be identical to the Aura model’s name in `Tiers`.

---

✅ **Summary:**

1. Place the Aura model in `ServerStorage/Tiers`.
2. Add an `Animations` folder if needed.
3. Apply effects to torso-related parts.
4. Remove unnecessary attachments and meshes.
5. Use the command script to disable collision and mass.
6. Set `AuraName` in `EquipScript` to match your Aura model’s name.
