import express, { Request, Response } from "express";

const app = express();
const PORT = process.env.PORT || 3000;

app.get("/", (req: Request, res: Response) => {
  res.send("Hello, World! Express server is running.");
});

export function startExpressServer() {
  app.listen(PORT, () => {
    console.log(`Express server is listening on port ${PORT}`);
  });
}
