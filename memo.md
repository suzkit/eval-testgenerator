# 二分探索でやったこと

## 目的
- テスト生成ツールに慣れる
- 簡単な人工バグを作ってみて、検出できるかどうか試してみる

## 実験手順
1. 正常なプログラムを用いて、KLEEでテスト生成。テスト生成に使用したのはハッシュ#`48ae774`のもの。
2. 人工的にバグを作り、コンパイル時にassertをoffにしてビルド
3. #1で作ったテストにかけて、テストが失敗するかどうかを確認する(回帰テストを想定)
   テストにはklee-replay.shを使う

## 結果
- アプリ非依存なバグ
  - メモリ: https://ja.wikipedia.org/wiki/%E3%83%A1%E3%83%A2%E3%83%AA%E5%AE%89%E5%85%A8%E6%80%A7
    - アクセスエラー
      - バッファオーバーリード
        - `1331941 out of bounds bug`
          - テストではエラーは出ず。ただ、KLEEはassert、およびout of bound pointerというNGを出した。
        - `64248e2 miscalc of mid index`
          - テストではエラーは出ず。ただ、KLEEはout of bound pointerというNGを出した。
        - `3ef4046 infinite loop bug`
          - 無限ループのためテスト終了せず。また、KLEEはout of bound pointerというNGを出した。
      - バッファオーバーフロー(書き込み)
        - `1331941 out of bounds bug`
          - テストではエラーは出ず。ただ、KLEEはassert、およびout of bound pointerというNGを出した。
      - [未実施]競合状態(ロックミスによる読み書き同時実行)
      - [未実施]無効ページフォルト
      - 解放後使用
        - テストでエラーが出て、KLEEはout of bound pointerというNGを出した。
      - [未実施]キャストの型ミス
    - [未実施]未初期化変数
      - [未実施]Null Pointerアクセス
      - [未実施]ワイルドポインタ(未初期化ポインタの参照)
    - メモリリーク
      - [未実施]スタックの枯渇
      - [未実施]ヒープの枯渇
      - 二重解放
        - 実行すれば必ず発現するが、invalid pointer: freeとして出る場合と、out of bound pointerとして出る場合両方ある
          - `74ac77f double free and klee said invalid pointer: free`
          - `9f27e7b double free but klee said out of bound pointer`
      - [未実施]無効な解放
      - [未実施]不一致な解放(複数のアロケータを使っている場合に、確保したアロケータと解放するアロケータが異なること)
      - [未実施]free忘れ
  - [未実施]メモリ以外
    - 無限ループ
    - デッドロック: ロックが取れなくて状態遷移できない
    - ライブロック: 自発的な内部遷移を繰り返し、外部からの要求に応答しなくなること
- アプリ依存なバグ
  - assertにひっかかるもの
    - `b080675 compare miss without assert`
      - 期待値がわからないので、KLEEでもテスト実行でもいずれにしても検出できない。
  - 性能不足

