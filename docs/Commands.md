# Commands

## データの追跡

```bash
dvc add data/raw/example.csv
dvc commit
git add data/raw/example.csv.dvc
git commit -m "feat: 生データ追加"
git tag -a "v1.0" -m "生データ追加"
git push origin v1.0
```
