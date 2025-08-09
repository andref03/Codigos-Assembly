# 🔧 Como executar o código `string_to_float.s` e ver a conversão

Abaixo estão os passos para compilar, rodar e depurar a conversão.
> **Observação:** atualize o ```tipo``` na seção ```section .data```

## 🧪 Execução do código:

```bash
as --64 string_to_float.s -o exe.o ; ld -o exe exe.o ; gdb ./exe
```

> Após rodar este comando, o GDB será iniciado. Pressione **Enter** quando necessário.

### Visualizar montagem dos bits no Padrão IEEE 754

```bash
as --64 string_to_float.s -o exe.o ; ld -o exe exe.o ; ./exe
```

---

## 🐞 Dentro do GDB:

### Para FLOAT (tipo = 0):

  ```gdb
  (gdb) b _fim_f
  (gdb) run
  (gdb) print $xmm0
  ```

### Para DOUBLE (tipo = 1):

  ```gdb
  (gdb) b _fim_d
  (gdb) run
  (gdb) print $xmm0
  ```
---

## 🧾 Interpretação da resposta:

A saída estará armazenada no registrador `xmm0`.  
Dependendo do tipo (`float` ou `double`), o GDB exibirá:

- **Para `float`** (`tipo = 0`):
  ```
  v4_float = {resposta, 0, 0, 0}
  ```

- **Para `double`** (`tipo = 1`):
  ```
  v2_double = {resposta, 0}
  ```

---

## ⚙️ Como mudar a entrada e o tipo:

No início do arquivo `string_to_float.s`, altere:

```asm
entrada: .asciz "-3.078"
tipo:    .long 0        # 0 = float, 1 = double
```

---

## ❌ Para sair do GDB:

```gdb
(gdb) q
```

## Teste para validar a Conversão

https://numeral-systems.com/ieee-754-converter/