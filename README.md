
# 🔧 Como executar o código `string_to_float.s` e ver a conversão

Abaixo estão os passos para compilar, rodar e visualizar o resultado da conversão.

## 🧪 Execução do código:

```bash
as --64 string_to_float.s -o exe.o  ; ld -o exe exe.o  ; gdb ./exe
```

> Pressione **Enter** após esse comando.

---

## 🐞 Dentro do GDB:

```gdb
(gdb) b _fim_func_float
(gdb) run
(gdb) print $xmm0
```

---

## 🧾 Interpretação da resposta:

A saída estará armazenada no registrador `xmm0`. Dependendo do tipo (`float` ou `double`), o GDB mostrará:

- Para `float` (`tipo = 0`):

  ```
  v4_float = {resposta, 0, 0, 0}
  ```

- Para `double` (`tipo = 1`):

  ```
  v2_double = {resposta, 0}
  ```

---

## ⚙️ Como mudar a entrada e o tipo:

Edite o início do código `string_to_float.s`:

```asm
entrada: .asciz "-3.078"
tipo:    .long 0        # 0 = float, 1 = double
```

---

## ❌ Para sair do GDB:

```gdb
(gdb) q
```
